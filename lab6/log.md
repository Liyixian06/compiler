Accept 11/38  
1,8,9,16,18 : internal_relocation (type: OFFSET_IMM) not fixed up  
26,27,47,48 : unknown pseudo-op: `.l5'  
46,51,1073 : segmentation fault  
49 : Execute Timeout  
50,56 : undefined reference to `addr_putint'  
57,1068,1070,1072 : ARM register expected -- `bx .L52'

---

Accept 17/38  
15, 17, 18, 19, 43, 44, 45 : Wrong Answer  

---

**01.16**

Accept 27/38  
46,51,1073 : segmentation fault  
这部分还没有 gdb 调试，参考：https://www.cnblogs.com/linux-37ge/p/12781176.html  

47,48,50,56,57,1068,1070,1072 : /usr/lib/gcc-cross/arm-linux-gnueabihf/9/../../../../arm-linux-gnueabihf/bin/ld: sysyruntimelibrary/libsysy.a(sylib.o): relocation R_ARM_THM_MOVW_ABS_NC against `__stack_chk_guard@@GLIBC_2.4' can not be used when making a shared object; recompile with -fPIC  
/usr/lib/gcc-cross/arm-linux-gnueabihf/9/../../../../arm-linux-gnueabihf/bin/ld: sysyruntimelibrary/libsysy.a(sylib.o)(.text+0x6): unresolvable R_ARM_THM_MOVW_ABS_NC relocation against symbol `__stack_chk_guard@@GLIBC_2.4'  
collect2: error: ld returned 1 exit status  
动态链接库的问题

---

level1-2:

12,41,100,102,1074,1076,1078,1083 :  
ARM register expected -- `str v0,[fp,#-20]`  
immediate expression requires a # prefix -- `mov r0,v34`  

---

**01.20**  
level1-1 Accept 35/38  
46,51,1073 - putint 接收外部输入问题