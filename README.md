# 通过Docker自动安装JupyterHub和LTI

[ ] docker-compose 自动运行？

 JupyterHub 是用于向Jupyter添加多用户功能的工具。 nbgrader与此配置集成在一起，使作业的提交和检索自动进行。 但是，它要求在学校使用托管该解决方案的服务器。 拥有这样的工具可以避免必须在本地安装jupyter，因为通过浏览器进行远程访问就足够了。
 
 在docker hub上的jupyterhub基础上，

** Docker **是一种轻便且功能强大的应用程序虚拟化工具。 它提供了独立于系统其余部分的jupyterhub环境。

安装步骤如下：
1. 收集制作Docker映像所需的材料
```console
git clone https://github.com/haharay/LtiJupyterHub.git
```
2. 在主机上安装docker。 在Linux中，只需键入
```console
apt-get install docker.io
```
docker.io是debian / ubuntu打包的docker版本。 如果您在使用此版本时遇到困难，则可以使用正式版docker-，此处描述了安装：

https://www.digitalocean.com/community/tutorials/comment-installer-et-utiliser-docker-sur-ubuntu-18-04-fr

使用这些版本中的一个或另一个将不会对其余版本进行任何更改。

3. 转到* jupyterhub *文件夹并构建您的Docker映像
```console
cd LtiJupyterHub
git pull origin master
docker build -t jupyter_lti .
```
别忘了 在第二个命令结束时的. ！

4. 启动镜像，把客户机的8000端口映射到主机的8090端口，或者在镜像中启动代理服务命令：
```console
docker run -i -p 8599:8000  jupyter_lti
docker run -i -p 8599:8000  --name jupyterhub jupyter_lti
docker run -d -p 8599:8000  --name jupyterhub jupyter_lti
```
5. 在主机上，执行以下命令，建立lti.xiaomy.net代理：
```console
nohup ./wyc_linux_64 -token=7ptm8xp0 &
ps -ef | grep wyc_linux_64
```


## LTI的设置

在edx的高级设置中，需要添加LTI账户：

"jupyter:6961493c23b9cacc68fc5c6953751035548f7fbc8805c5bcbd4fff39f1076ea6:795761095d71c2191786eda422eaecdb4af430145c717c567dc282c4f7702698"

然后，使用高级模块添加LTI组件或者是构造课件组件。
网址：http://10.8.116.47:8599/
    http://10.8.116.47:8599/hub/lti

## 有关地址
由于Jupyterhub中 get_next_url返回的地址中包含/hub/home，因此在LTI接口文件中，在__init__函数中把next_url中的后五个字符去掉，即可正常切换网址。
其他参数：LTI服务器地址：lti.xiaomy.net
[ ] 注意：目前不能nbgitpuller导入文件。


```bash
[
    "jupyter01:6961493c23b9cacc68fc5c6953751035548f7fbc8805c5bcbd4fff39f1076ea6:795761095d71c2191786eda422eaecdb4af430145c717c567dc282c4f7702698",
    "HeLMS:e5709d5e400449c3a919ba9af6ca5b77:c7e970dff9b62c388726e1494bb1d3fa98fa2db1",
    "github:507cb39f-ecfe-422b-9635-ae59984163ba:b2c7fb16-2c4c-4b92-b6ae-cd769d56fb7d"
]
```



## 课程安排

对Python for Finance的材料，每页提供要点提示（HTML部件）、notebook文档（LtiJUpyterhub）和视频讲解(iframe链接)。


## 补充：数据持久化
删除当前的jupyterhub实例。
```bash
docker stop jupyterhub
docker rm jupyterhub
```
建立数据存储卷：
```bash
docker volume rm jupyterhub_data
docker volume create jupyterhub_data

```
这样创建容器的命令就变成：
```bash
docker run -it --name jupyterhub -p 8599:8000 -v jupyterhub_data:/home jupyter_lti
```
断电后，重新打开、stop命名容器：
```bash
docker start -i jupyterhub
docker start jupyterhub
```
### 备份与恢复数据

去掉：texlive-generic-recommended \, john,hashcrack(安装麻烦)

## Julia和R的参考更新网址：
https://github.com/jupyter/docker-stacks
https://github.com/jupyter/docker-stacks/blob/master/datascience-notebook/Dockerfile

