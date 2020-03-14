import os
from pwd import getpwnam


# 需要配置 headers ，否则无法通过 frame 集成
c.JupyterHub.tornado_settings = {
    'headers': {
        'Content-Security-Policy': "frame-ancestors *"
  }
}
# 修改认证器
from IPython.utils.localinterfaces import public_ips
c.JupyterHub.hub_ip = public_ips()[0]
c.Authenticator.admin_users = {'adminjh'}
c.JupyterHub.api_tokens = {
    'f05ebd3853894ecccfc8c8b4d139618a' : 'adminjh',
}
c.JupyterHub.allow_named_servers = True
c.LocalAuthenticator.create_system_users = True
c.DummyAuthenticator.password = "toto"
from ltiauthenticator import LTIAuthenticator
from jupyterhub.auth import LocalAuthenticator
class LocalLtiAuthenticator(LocalAuthenticator, LTIAuthenticator):
    pass
c.JupyterHub.authenticator_class = 'ltiauthenticator.LTIAuthenticator'
c.JupyterHub.authenticator_class = LocalLtiAuthenticator
c.LTIAuthenticator.consumers = {
    "6961493c23b9cacc68fc5c6953751035548f7fbc8805c5bcbd4fff39f1076ea6":"795761095d71c2191786eda422eaecdb4af430145c717c567dc282c4f7702698"
}
c.NotebookApp.allow_remote_access = True

# LDAP
#c.JupyterHub.authenticator_class = 'ldapauthenticator.LDAPAuthenticator'
#c.LDAPAuthenticator.server_address = '10.124.56.4:389'
#c.LDAPAuthenticator.bind_dn_template = "uid={username},ou=People,dc=allende,dc=lyc14,dc=ac-caen,dc=fr"
#c.LDAPAuthenticator.lookup_dn_search_user = "ou=People,dc=allende,dc=lyc14,dc=ac-caen,dc=fr"

def my_hook(spawner):
    username = spawner.user.name
    path = "/home/"+username

    try:
        os.mkdir(path)
    except OSError:
        print ("Creation of the directory %s failed" % path)
    else:
        print ("Successfully created the directory %s " % path)
        os.chown(path, getpwnam(username)[2],getpwnam(username)[3] )
        os.chmod(path,0o700)

c.Spawner.pre_spawn_hook = my_hook
