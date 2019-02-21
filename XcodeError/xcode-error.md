近期赶项目，遇到了一些xcode的问题，做一下记录整理

1. 第三方字体导入问题

导入一个 BebasNeueBold，各个步骤完全没有错误，plist用的是Property List表方式导入的。但是问题就是出在Property List方式，转换成Source Code发现转义不对，导致获取字体获取一直未nil。

**正确的方式在Source Code应该如下：**

```
<key>UIAppFonts</key>

<array>

         <string>BebasNeueBold.TTF</string>

 </array>

```

2. xcode包含多个子库源码时候build时，编译出错

```
error: unable to spawn process (Argument list too long)
```

**解决方法：**

去报错的子库，**Build Settings -->Header Search Paths** 把相关的第三方库改成non-recursive，本地库recursive删除多余的导入，确保每个文件只导入一次。

![image](https://github.com/code1303009/learning-recording/raw/master/XcodeError/images/三方库.png)

三方库

![image](https://github.com/code1303009/learning-recording/raw/master/XcodeError/images/本地库.png)

本地库