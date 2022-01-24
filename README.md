# magiskboot_and_patch_win
magiskboot binary on windows with a patch script

```
 Usage:
  boot_patch.bat ^<boot image^> ^<is 64 bit^> ^<keepverity^> ^<keepforceencrypt^>
      You can just provide boot.img
      But if you want different patch just provide more args
  Example:
  boot_patch.bat boot.img true true true
  Explain:
      Is64Bit : if your device is 64 bit device set arg2 is true default is [true]
      KEEPVERITY : if you want keep verity like dm-verity avb-verity in fstab or dt file
      KEEPFORCEENCRYPT : As it says keep force encrypt
      
```

*enjoy~* <br>

# x86 not support，you can change binary files to support x86
arm is default

# Issues
*On some mt6735/mt6737 device ,the file generate new-boot.img size is too large as 4GB ,dont know how to fix...

# Version
script version 1.1
magiskboot binary file version is 2021.9.3 clone from magisk/native/jni
