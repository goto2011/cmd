
# 1. dos
	1. 加view边框：setprop debug.layout true
	2. 
monkey：monkey -p com.camera 参数很多
	3. 
logcat > logfile
	4. 
截图：screencap -p filename
	5. 
getprop
	6. 
change prop: pull 到本地，用写字板修改，然后再push回去，改权限644，最后重启。
	7. 
adb wait-for-device
	8. 
循环处理：delims
	9. 
dumpsys, 支持多个参数



# 2. Log

	1. beginning of main / beginning of system / beginning of crash
	2. 
系统进入桌面：system now ready
	3. 
crash / fatal / backtrace / died / watchdog / goodbye / shutting down vm / Androidruntime /  am_crash / am_kill / service crashed / java.lang.runtimeexception / exit zygote / backtrace
	4. 
Err / fail / unexpected / system.err / java.lang
	5. 
held by / blocked / caused by / locked / waiting on / locked
	6. 
Inputreader / inputdispatcher / eventhub / inputmanager_dispatch 
	7. 
ANR in / Input event dispatching timed out /     App freeze 
	8. 
接收广播： received broadcast / onReceive / 太多，建议直接搜广播名
	9. 
Usb对话框： showMtpDialog : mode
	10. 
Log溢出：identical
	11. 
binder溢出：binder_alloc_buf, no vma 
	12. 
应用启动：Start proc / New app record ... pid=   / Displayed
	13. 
应用丢帧：Skipped 33 frames / Choreographer
	14. 
焦点窗口：Set focused app to
	15. 
Systrace
	16. 



# 3. following

	1. 本地工作代码管理

		1. 
本地放一套代码做完工作代码，写代码读代码过程中随时加注释。
		2. 
每周一，库上的代码备份一套。然后把new-old比较出来。然后合入最新代码，作为新的工作代码。
		3. 
new-old 要每周备份。
		4. 
as中导出注释，对比，确保不漏。
		5. 
// dg1  代码
		6. 
// dg2  注释
		7. 
打印堆栈：new Exception();
	2. 
工具：

		1. 
total commander
		2. 
sublime text

			1. 
管理知识库，也支持图片，所以关键信息截图保存，并准确命名。
			2. 
project - add folder to project
			3. 
view - show side bar
		3. 
beyond compare

			1. 
代码对比、代码上库，保存为会话
		4. 
text analysis tool.net

			1. 
注意备份 tat 文件。
		5. 
mobaxterm
		6. 
everything

			1. 
常用路径存为书签。
	3. 
日常操作脚本化

		1. 
推apk
		2. 
抓log
		3. 
清log
		4. 
截屏
		5. 
重启
		6. 
加、去 界面边框
		7. 
修改语言
		8. 
备份prop项
		9. 
修改prop项
		10. 
monkey
		11. 
dump yuv
		12. 
下载数据库
		13. 
清数据库
	4. 
界面型问题，务必截图，一图胜千言。
	5. 
看代码，首先用一句话总结下每个类的功能，及类间关系。
	6. 
看文档时，关注大流程、多线程、互斥关系和定制项。
	7. 


