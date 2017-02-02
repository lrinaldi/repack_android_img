# repack_android_img

Tool for joining splitted ROM images, based on rawprogram_unsparse.xml

Make sure you are in the same folder than rawprogram_unsparse.xml and splitted images (ex : system_1.img, system_2.img...)

# usage :
```
      repack_android_img.pl [-l label] [-f file]

     -l label  : partition label
     -f file   : xml file data (default : rawprogram_unsparse.xml)
     -m        : write missing block at the end of the file (not implemented yet)

    example: repack_android_img.pl -l system -f rawprogram_unsparse.xml
```

# tools :

Pre-compiled (linux x86-64) tools for android image manipulation can be found in external/android_img_repack_tools/bin/x86-64/
