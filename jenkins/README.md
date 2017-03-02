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

* [Checkstyle](http://wiki.jenkins-ci.org/display/JENKINS/Checkstyle+Plugin)(处理[PHP_Codesniffer](https://github.com/squizlabs/PHP_CodeSniffer)日志)

* [Clover PHP](http://wiki.jenkins-ci.org/display/JENKINS/Clover+PHP+Plugin)(处理[PHPUnit](https://github.com/squizlabs/PHP_CodeSniffer) 的clover日志)

* [Crap4j](http://wiki.jenkins-ci.org/display/JENKINS/Crap4J+Plugin)

* [DRY](http://wiki.jenkins-ci.org/display/JENKINS/DRY+Plugin)(处理[phpcpd](https://github.com/sebastianbergmann/phpcpd)的日志)

* [HTML Publisher](http://wiki.jenkins-ci.org/display/JENKINS/HTML+Publisher+Plugin)(处理[phpdox](http://phpdox.de/)生成的文档)

* [JDepend](http://wiki.jenkins-ci.org/display/JENKINS/JDepend+Plugin)

* [Plot](http://wiki.jenkins-ci.org/display/JENKINS/Plot+Plugin)(处理[PHPLOC](https://github.com/sebastianbergmann/phploc)的输出)

* [PMD](http://wiki.jenkins-ci.org/display/JENKINS/PMD+Plugin)(处理[phpmd](http://phpmd.org/)的日志)

* [Violations](http://wiki.jenkins-ci.org/display/JENKINS/Violations)()

* [Warings](https://wiki.jenkins-ci.org/display/JENKINS/Warnings+Plugin)

* [XUnit](http://wiki.jenkins-ci.org/display/JENKINS/xUnit+Plugin)

需要安装的PHP工具：

* [PHPUnit](https://github.com/squizlabs/PHP_CodeSniffer)

* [PHP_Codesniffer](https://github.com/squizlabs/PHP_CodeSniffer)

* [PHPLOC](https://github.com/sebastianbergmann/phploc)

* [PHP_Depend](http://pdepend.org/)

* [PHPMD](http://phpmd.org/)

* [PHPCPD](https://github.com/sebastianbergmann/phpcpd)

* [phpDox](http://phpdox.de/)

可以下载phar文件，或者用composer来安装这些工具，但是要把它们加到变量PATH里，最后可以通过 `phpunit`, `phpcs`, `phploc`, `pdepend`, `phpmd`, `phpcpd`, 以及 `phpdox` 来调用


### 自动化构建

用Apache Ant来调度自动化构建过程。构建的过程是通过build.xml来设置的（[点此下载](https://github.com/suhelen/baiyang/blob/master/jenkins/build.xml)）。此构建脚本假定PHP_Codesniffer, phpdox, phpmd 及 phpunit 的配置文件存在于 `build/phpcs.xml`, `build/phpdox.xml`, `build/phpmd.xml`, `build/phpunit.xml`。

构建之前项目的目录结构如下：

```
src
tests
build.xml
build
|-- phpcs.xml
|-- phpdox.xml
|-- phpmd.xml
`-- phpunit.xml
```

构建之后：

```
src
tests
build.xml
build
|-- phpcs.xml
|-- phpdox.xml
|-- phpmd.xml
|-- phpunit.xml
|-- api ...
|-- coverage ...
`-- logs
    |-- checkstyle.xml
    |-- clover.xml
    |-- crap4j.xml
    |-- jdepend.xml
    |-- junit.xml
    |-- phploc.csv
    |-- pmd-cpd.xml
    `-- pmd.xml
```

 
