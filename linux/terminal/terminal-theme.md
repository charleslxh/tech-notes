```shell
    PS1="\[\e[35m\]\u\[\e[36m\] \[\e[32m\]\w\[\e[36m\] "'$(__git_ps1 "<(\[\e[31m\]%s\[\e[36m\])>")'"\$ "
```
## config method

```shell
    vim ~/.bashrc
```

*add that code into that file.* then run `source ~/.bashrc` and restart terminal.

### The following is the details of SP1 configuration

The meaning of every `Variable`:

| Variable Name        | Description           |
| :----------:|:--------------|
| `\d` | 代表日期，格式为weekday month date，例如：Wed Dec 12
| `\H` | 完整的主机名称。例如：hostname是debian.linux
| `\h` | 仅取主机的第一个名字，如上例，则为debian，.linux则被省略
| `\t` | 显示时间为24小时格式，如：HH：MM：SS
| `\T` | 显示时间为12小时格式
| `\A` | 显示时间为24小时格式：HH：MM
| `\u` | 当前用户的账号名称 如：root
| `\v` | BASH的版本信息  如:3.2
| `\w` | 完整的工作目录名称。家目录会以 ~代替 如显示/etc/default/
| `\W` | 利用basename取得工作目录名称，所以只会列出最后一个目录 如上例则只显示default
| `\#` | 下达的第几个命令  www.2cto.com  
| `\$` | 提示字符，如果是root时，提示符为：# ，普通用户则为：$

### The following is the details of color

The color pattern is `\[\e[F;Bm\]`, `F` stand for the font color and `B` for setting the background color.

| Font Color Number | Background color NUmber | Color |
| :----------:|:--------------|:------------------|
| `0`  | `0` | Reset the color |
| `30` | `40` |  Red |
| `31` | `41` |  Black |
| `32` | `42` |  Green |
| `33` | `43` |  Yellow |
| `34` | `44` |  Blue |
| `35` | `45` |  Pink |
| `36` | `46` |  Cyan |
| `37` | `47` |  White |
