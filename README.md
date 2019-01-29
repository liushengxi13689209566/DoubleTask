
# sanke-triangle
一个可以学习的小demo

# 一、题目设计
双任务系统设计

# 二、设计内容
采用8086汇编语言，设计并实现双任务系统设计，对两个任务（两个窗口）进行管理和调度，能够实现任务之间的切换，保存上下文信息。任务调度程序使用循环程序来完成。在左边显示窗口，能够运行简单的贪吃蛇游戏，在右边显示窗口，能够画出等边三角形。
# 三、 需求分析
1. 贪吃蛇游戏采用键盘按键控制贪吃蛇前进方向，如“W、S、A、D”键分别为上下左右方向控制按键。
2. 游戏终止条件为贪吃蛇碰触窗口边框、蛇头碰触身体、身体长度达到上限，以“R”键为游戏重新开始。若游戏进行当中无键按下，则贪吃蛇保持当前方向不变直至撞墙。
3. 等边三角形位置在该显示区域的中部，参数边长由键盘输入确定。
4. 三角形每次根据输入的参数，在该窗口将三角形重新绘制出来。
5. 初始工作窗口为右边显示窗口，以后每按一次Tab键切换至旁边显示窗口。
6. 当某个显示窗口被选中时，则焦点停留在该窗口，键盘输入对当前窗口有效。
7.  整个系统按ESC键退出，返回DOS操作系统界面。

# 四、 概要设计
### 1. 方案设计
功能肢解：
    ![在这里插入图片描述](https://img-blog.csdnimg.cn/20181208203138914.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1dlbGtpbl9xaW5n,size_16,color_FFFFFF,t_70)

### 2. 模块功能说明

##### 2.1 I/O模块说明

（1）getInt() 读入整数函数：键盘输入一串字符，检测该字符是否为数字字符。若不是数字字符，则做无效处理。直至输入完整的数值字符保存在AX中并将ZF置1（调用者可用JZ判断是否发生特殊情况）。并做如下处理：①若键盘输入Esc键，返回AX=0，并将ZF置0。②若键盘输入Tab键，返回AX=1，并将ZF置0。

（2）getchar() 函数：输入一个字符，回显

（3）puts() 函数：输出字符串
（4）getch() 函数：输入一个字符，不回显
（5）putInt() 函数：将AX寄存器中的数字以十进制的形式输出

##### 2.2 控制模块说明
（1）movCursor() 移动光标模块：将光标移动至y行x列
（2）sDelay() 延时函数模块：控制贪吃蛇移动速度
（3）kbhit() 模块：检测键盘有无输入
（4）rand() 随机数发生模块：生成一定范围内的随机数


# 五、详细设计及运行结果
### 5.1 流程图
（1）	三角形模块流程图

 ![三角形](https://img-blog.csdnimg.cn/20181208203238605.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1dlbGtpbl9xaW5n,size_16,color_FFFFFF,t_70)

（2）贪吃蛇模块流程图
 
 ![贪吃蛇](https://img-blog.csdnimg.cn/20181208203310715.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1dlbGtpbl9xaW5n,size_16,color_FFFFFF,t_70)



### 5.2 函数之间相互调用的图示
- 函数内部调用图：
 ![内部调用](https://img-blog.csdnimg.cn/20181208203430889.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1dlbGtpbl9xaW5n,size_16,color_FFFFFF,t_70)

- 顶层调用图示：
 


![顶层调用](https://img-blog.csdnimg.cn/20181208203457119.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1dlbGtpbl9xaW5n,size_16,color_FFFFFF,t_70)







### 5.3 程序设计主要代码
- 任务切换：
 
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181208203540303.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1dlbGtpbl9xaW5n,size_16,color_FFFFFF,t_70)











- 贪吃蛇移动：
 
 ![在这里插入图片描述](https://img-blog.csdnimg.cn/20181208203607720.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1dlbGtpbl9xaW5n,size_16,color_FFFFFF,t_70)

![在这里插入图片描述](https://img-blog.csdnimg.cn/20181208203629250.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1dlbGtpbl9xaW5n,size_16,color_FFFFFF,t_70)

- 画三角形主要流程：

 ![画三角形主要流程](https://img-blog.csdnimg.cn/20181208203704506.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1dlbGtpbl9xaW5n,size_16,color_FFFFFF,t_70)

### 5.4 运行结果

1. 开始界面

 ![开始界面](https://img-blog.csdnimg.cn/20181208203733801.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1dlbGtpbl9xaW5n,size_16,color_FFFFFF,t_70)

2. 输入等边三角形边长
- 2.1 若输入超出范围，清除输入数据并等待重新输入（此处为500）
 
![输入边长](https://img-blog.csdnimg.cn/20181208203808652.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1dlbGtpbl9xaW5n,size_16,color_FFFFFF,t_70)













- 2.2输入符合规范（此处为200）
 
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181208203924768.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1dlbGtpbl9xaW5n,size_16,color_FFFFFF,t_70)

3. 按Enter画等边三角形并重新打印提示信息
 


![在这里插入图片描述](https://img-blog.csdnimg.cn/20181208203941453.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1dlbGtpbl9xaW5n,size_16,color_FFFFFF,t_70)













4. 可循环读入等边三角形边长（此处为80）

 ![在这里插入图片描述](https://img-blog.csdnimg.cn/20181208204020273.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1dlbGtpbl9xaW5n,size_16,color_FFFFFF,t_70)

5、按Enter清除右半部分屏幕并重新打印
 




![在这里插入图片描述](https://img-blog.csdnimg.cn/2018120820410187.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1dlbGtpbl9xaW5n,size_16,color_FFFFFF,t_70)












6、按Tab键画等边三角形程序停止，贪吃蛇程序开始运行
 
 ![在这里插入图片描述](https://img-blog.csdnimg.cn/20181208204125513.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1dlbGtpbl9xaW5n,size_16,color_FFFFFF,t_70)

7. 食物出现在随机位置，用W A S D键控制贪吃蛇运动。
 
 ![在这里插入图片描述](https://img-blog.csdnimg.cn/20181208204227658.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1dlbGtpbl9xaW5n,size_16,color_FFFFFF,t_70)

8. 若撞墙或碰到自己游戏结束并暂停
 
 ![在这里插入图片描述](https://img-blog.csdnimg.cn/20181208204245929.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1dlbGtpbl9xaW5n,size_16,color_FFFFFF,t_70)

9. 游戏过关
 
 ![在这里插入图片描述](https://img-blog.csdnimg.cn/20181208204317809.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1dlbGtpbl9xaW5n,size_16,color_FFFFFF,t_70)
 
10. 按R键重新开始游戏
 
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181208204336475.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1dlbGtpbl9xaW5n,size_16,color_FFFFFF,t_70)

11. 按Tab键贪吃蛇程序暂停，画等边三角形程序等待输入
 
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181208204352492.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1dlbGtpbl9xaW5n,size_16,color_FFFFFF,t_70)

# 六、 调试情况，设计技巧及体会

### 1. 对自己设计进行评价，指出合理和不足之处，提出改进的方案。
- 不足：

（1）贪吃蛇游戏制作的精细度和画面质量有待提高。

（2）贪吃蛇的移动速度无法改变。

（3）三角形使用整数近似计算。

- 改进：

（1）可以通过改变蛇身的样子和食物的颜色来提高画面质量。

（2）可以在界面中设置游戏的速度：慢速 中速 高速。

（3）三角形可使用浮点数寄存器进行划线。

### 2. 在设计过程中的感受。

在本次竞赛学习过程中，项目经过功能划分、肢解分为一层一层的模块调用。将计算机基本指令和中断调用整合起来形成底层模块，再由底层模块整合起来形成较大的功能模块，再由功能模块进行逻辑组合形成snake和tri模块，使用yield任务切换模块作为桥梁将整个程序整合在一起。

在实际操作中我们认识到熟练掌握汇编语言中的指令的基本用法和组织结构的重要性。只有熟练掌握指令的基本用法，我们才能在实际的编程中像运用高级语言一样灵活的变通，认清计算机组织结构才能灵活设计程序整体架构。汇编语言作为一种低级设计语言，它是最底层的、与计算机内部的结构联系密切，我们在这次竞赛过程中深刻地了解到了这一点。

在贪吃蛇程序和画等边三角形的程序设计中，加深了对计算机体系结构的理解，深刻理解汇编语言和其他语言的不同。在代码设计中也遇到很多的困难，比如一些寄存器使用冲突的问题，还有一些宏的使用问题和两个程序切换的问题等，以及如何对程序调用时对参数和返回值做一系列约定。在这个方面，我们深刻理解了团队协作能力的重要性。

# 七、参考资料

·腾讯libco协程库coctx_cwap.S上下文切换模块:
https://github.com/Tencent/libco/blob/master/coctx_swap.S
·CSDN博客
·百度文库
·《汇编语言》王爽

















