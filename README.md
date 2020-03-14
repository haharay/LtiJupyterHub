# 通过Docker自动安装JupyterHub和LTI

[ ] docker-compose 自动运行？

 JupyterHub 是用于向Jupyter添加多用户功能的工具。 nbgrader与此配置集成在一起，使作业的提交和检索自动进行。 但是，它要求在学校使用托管该解决方案的服务器。 拥有这样的工具可以避免必须在本地安装jupyter，因为通过浏览器进行远程访问就足够了。

** Docker **是一种轻便且功能强大的应用程序虚拟化工具。 它提供了独立于系统其余部分的jupyterhub环境。

安装步骤如下：
1. 收集制作Docker映像所需的材料
```console
git clone https://github.com/haharay/LtiJUpyterhubDocker.git
```
2. 在您的机器上安装docker。 在Linux中，只需键入
```console
apt-get install docker.io
```
docker.io是debian / ubuntu打包的docker版本。 如果您在使用此版本时遇到困难，则可以使用正式版docker-，此处描述了安装：

https://www.digitalocean.com/community/tutorials/comment-installer-et-utiliser-docker-sur-ubuntu-18-04-fr

使用这些版本中的一个或另一个将不会对其余版本进行任何更改。

3. 转到* jupyterhub *文件夹并构建您的Docker映像
```console
cd LtiJUpyterhubDocker
docker build -t jhub_srv .
```
别忘了 在第二个命令结束时的. ！

4. 启动镜像：
```console
docker run -i -p8000:8090  jhub_srv
```

** jupyterhub **服务器现在可以运行。 打开浏览器并转到地址
http://127.0.0.1:8000（或http：// _ your_ip_address：8000，通过网络）。 您可以使用accounts.csv文件中存在的登录名（例如，prof1 / wawa）开始测试教授帐户。

## LTI的设置

在edx的高级设置中，需要添加LTI账户：

"jupyter01:6961493c23b9cacc68fc5c6953751035548f7fbc8805c5bcbd4fff39f1076ea6:795761095d71c2191786eda422eaecdb4af430145c717c567dc282c4f7702698"

然后，使用高级模块添加LTI组件或者是构造课件组件。

## 课程安排

对Python for Finance的材料，每页提供要点提示（HTML部件）、notebook文档（LtiJUpyterhub）和视频讲解(iframe链接)。

## 管理持久数据
Si vous mettez en place un serveur en production, vous voudrez que vos données survivent même si vous effacez le container pour en reconstruire un propre à partir d'une image. Les **volumes** docker sont vos amis ! Grâce à eux, vous pourrez externaliser le stockage de certains dossiers hors du container. Pour cette installation de jupyterhub, je recommande deux volumes 
- un volume pour les espaces personnels de stockage (jh_home)
- un volume pour la zone d'échange nbgrader (jh_exchange)

Pour créer ces deux volumes, tapez les commandes suivantes
```console
docker volume create jh_home
docker volume create jh_exchange
```

Pour créer un container utilisant ces volumes, il faut juste ajouter le paramètre 

  -v NOM_VOLUME:ARBO_DANS_CONTAINER :

```console
docker run -it --name jhub -p 8000:8000 -v jh_home:/home -v jh_exchange:/srv/nbgrader/exchange wawachief/jupyterhub
```

et voilà, en modifiant juste la ligne de création du container, vos données sont persistantes ! Vous pouvez effacer le container et en recréer un, vous retrouverez vos données. Vous avez maintenant un serveur opérationnel pour la production.

### Sauvegarde et restauration des données

Dans la commande ci-dessous, nous allons créer un nouveau container basé sur une ubuntu qui va accéder aux volumes de notre container nommé **jhub** et fabriquer une archive *tar* qui sera stockée dans le répertoire courant de la machine hôte. L'option **--rm** permet d'effacer ce container temporaire qui ne sert qu'à la récupération des données.
```console
docker run --rm --volumes-from jhub -v $(pwd):/backup ubuntu tar cvf /backup/backup.tar /home /srv/nbgrader/exchange
```
La ligne suivante va restaurer l'archive **backup.tar** réalisée ci-dessus d'un nouveau container **jhub_new** que l'on a déjà lancé.
```console
docker run --rm --volumes-from jhub_new -v $(pwd):/backup ubuntu bash -c "cd / && tar xvf /backup/backup.tar"
```
Ces deux méthodes montrent donc comment transférer le contenu d'un container à un autre. On peut ainsi migrer facilement une installation jupyterhub sur une autre machine.

## Quelques commandes docker utiles :
- Pour fermer l'image, tapez CTRL+C

- Pour réouvrir à nouveau ce container, 
```console
docker start -i jupyterhub
```

- Pour connaître la liste des containers
```console
docker ps -a
```

- Pour connaître la liste des images
```console
docker images
```

- Pour effacer un container (afin de repartir de l'image propre, par exemple de début d'année)
**Attention** les données contenues dans le container seront **détruites** !!!
```console
docker rm CONTAINER_ID
```
- Pour effacer l'image construite (attention !) :
```console
docker rmi jhub_srv
```

- pour lister les volumes :
docker volume ls

- pour avoir des informations sur un volume :
docker volume inspect my-vol
