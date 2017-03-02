# Jenkins管理PHP项目

## 代码审查

在开发和维护Web应用程序的过程中，需要对软件质量进行监控并持续改进。下面为php项目提供一个Jenkins job的模板

以下几步就能实现：

1. 安装软件：Apache, Jenkins, PHP, Apache Ant

2. 安装Jenkins插件和PHP工具

3. 用Apache Ant自动化构建过程

4. 配置php工具

5. 创建jenkins job

### 安装

#### Jenkins Plugins

需要安装的jenkins插件：

* [Checkstyle](http://wiki.jenkins-ci.org/display/JENKINS/Checkstyle+Plugin)(处理PHP_Codesniffer日志)

* [Clover PHP](http://wiki.jenkins-ci.org/display/JENKINS/Clover+PHP+Plugin)(处理PHPUnit 的clover日志)

* [Crap4j](http://wiki.jenkins-ci.org/display/JENKINS/Crap4J+Plugin)

* [DRY](http://wiki.jenkins-ci.org/display/JENKINS/DRY+Plugin)(处理[phpcpd](https://github.com/sebastianbergmann/phpcpd)的日志)

* HTML Publisher

* JDepend

* Plot



