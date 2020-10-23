import os
import pwd
import subprocess
#from pwd import getpwnam


# 需要配置 headers ，否则无法通过 frame 集成
c.JupyterHub.tornado_settings = {
    'headers': {
        'Content-Security-Policy': "frame-ancestors *"
  }
}
# 修改认证器
from jupyter_client.localinterfaces import public_ips
c.JupyterHub.hub_ip = public_ips()[0]
c.Authenticator.admin_users = {'adminlti'}
c.Authenticator.delete_invalid_users = True
c.JupyterHub.service_tokens = {
    'f05ebd3853894ecccfc8c8b4d139618a': 'adminlti',
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

#def pre_spawn_hook(spawner):
#    username = spawner.user.name
#    try:
#        pwd.getpwnam(username)
#    except KeyError:
#        subprocess.check_call(['useradd', '-ms', '/bin/bash', username])
#
#c.Spawner.pre_spawn_hook = pre_spawn_hook
