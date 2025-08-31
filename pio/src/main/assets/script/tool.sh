# Create new project
[ -e ${XBJ} ] && xm=$(cat ${XBJ})
[ ! -d $mdir/$xm ] && mkdir -p $mdir/$xm
dg() {
  [ -f $zml/$xm/super.img ] && echo "super.img"
  [ -f $zml/$xm/payload.bin ] && echo "payload.bin"
}
readdt() {
  if [ -e $zml/$xm/super.img ]; then
    utils lpdump $zml/$xm/super.img
  fi
  if [ -e $zml/$xm/payload.bin ]; then
    for i in $(utils payload_dump $zml/$xm/payload.bin); do
      echo "$i"
    done
  fi
}
extract_part() {
  Extract=$zml/image
  IFS=$'\n'
  [[ ! -d "$Extract" ]] && mkdir -p "$Extract"

  for i in ${IMG}; do
    e=${i##*/}
    File="$Extract/${e}.img"
    [[ ! -L ${i} ]] && echo "! The $e partition does not exist and cannot be extracted"
    echo "- Starting extraction of $e partition"
    dd if="${i}" of="$File"
    echo "- Extracted $e partition to: $File"
    echo
  done
}
parts() {
  if [[ 0 ]]; then
    a=0
    b=($(ls /dev/block/))
    for i in ${b[@]}; do
      [[ -d /dev/block/${i} ]] && unset b[$a]
      a=$((a + 1))
    done
    BLOCKDEV=$(which blockdev)

    find /dev/block -type l | while read o; do
      [[ -d "$o" ]] && continue
      c=$(basename "$o")
      echo ${b[@]} | grep -q "$c" && continue
      echo $c
    done | sort -u | while read Row; do
      BLOCK=$(find /dev/block/by-name -name $Row | head -n 1)
      if [[ -n $BLOCKDEV ]]; then
        size=$(blockdev --getsize64 $BLOCK)
        if [[ $size -ge 1073741824 ]]; then
          File_Type=$(awk "BEGIN{print $size/1073741824}")G
        elif [[ $size -ge 1048576 ]]; then
          File_Type=$(awk "BEGIN{print $size/1048576}")MB
        elif [[ $size -ge 1024 ]]; then
          File_Type=$(awk "BEGIN{print $size/1024}")kb
        elif [[ $size -le 1024 ]]; then
          File_Type=${size}b
        fi
        [ "$File_Type" != "b" ] && echo "$BLOCK|$Row Size: $File_Type"
      else
        echo "$BLOCK|$Row"
      fi
    done
  fi
}
tqdgjx() {
  if [ -f $zml/$xm/super.img ]; then
    [ "$(utils utils gettype $zml/$xm/super.img)" = "sparse" ] && str $zml/$xm/super.img
  fi
  if [ $qptq = 1 ]; then
    if [ "$tqjx" = "super.img" ]; then
      echo "- Extracting: super.img"
      utils lpunpack $zml/$xm/super.img $zml/$xm/
      errorlevel=$?
      if [ $? = 0 ] && [ $del = 1 ]; then
        rm -rf $zml/$xm/super.img
      else
        [ $errorlevel = 1 ] && warn "Error occurred while unpacking super"
      fi
    fi
    if [ "$tqjx" = "payload.bin" ]; then
      echo "- Unpacking: payload.bin"
      utils payload_all $zml/$xm/payload.bin $zml/$xm/
      if [ $? = 0 ] && [ $del = 1 ]; then
        rm -rf $zml/$xm/$tqjx
      fi
    fi
    exit 0
  fi
  for i in ${jxs}; do
    echo "- Extracting $i"
    [ "$tqjx" = "super.img" ] && utils lpunpack $zml/$xm/super.img $zml/$xm/ ${i} 1
    [ "$tqjx" = "payload.bin" ] && utils payload $zml/$xm/payload.bin $zml/$xm/ $i
  done
  [ $del = 1 ] && rm -rf $zml/$xm/$tqjx
  for i in $(ls *_a.img); do
    echo "Renaming $i to $(echo $i | sed 's/_a//g')"
    mv $i $(echo $i | sed 's/_a//g')
  done
}
cm() {
  for i in $(ls -d $START_DIR/module/*/); do
    basename $i
  done
}
flash_img() {
  [[ -z ${iMG} ]] && error "flash"
  IFS=$'\n'
  e=${IMG##*/}
  echo "- You have currently selected the $e partition"
  echo "- Flash file path: $Brush_in"
  echo "- Checking if flash image file exists"
  [[ ! -L "${i}MG" ]] && abort "! The $e partition does not exist and cannot be flashed"
  if [[ -f "$Brush_in" ]]; then
    echo "- Starting to flash $e partition"
    dd if="$Brush_in" of="${i}MG"
    if [[ $CQ = 1 ]]; then
      echo "About to restart to recovery mode, countdown starting..."
      for i in $(seq 4 -1 1); do
        echo ${i}
        sleep 1
      done
      reboot recovery
    fi
    if [[ $CQ1 = 1 ]]; then
      echo "About to restart the phone, countdown starting..."
      for i in $(seq 4 -1 1); do
        echo ${i}
        sleep 1
      done
      reboot
    fi
  else
    error "! Flash file $Brush_in does not exist, cannot flash to $e partition, operation"
  fi
  echo "- Complete"
  sleep 2
}
gszh() {
  i=$IMG
  info=$(utils gettype $zml/$xm/${i}.img)
  for i in ${IMG}; do
    if [ $gs = sparse ]; then
      if [ $info = "ext" ] || [ $info = "erofs" ] || [ $info = "super" ]; then
        rts $zml/$xm/${i}.img
      fi
      [ $info = "sparse" ] && warn "${i} is already in sparse format"
    fi
    if [ $gs = raw ]; then
      if [ $info = "ext" ] || [ $info = "erofs" ] || [ $info = "super" ]; then
        warn "$i is already a raw image"
      fi
      [ $info = "sparse" ] && rts $zml/$xm/${i}.img
    fi
    if [ $gs = dat ] || [ $gs = br ]; then
      [ $info = "ext" ] && rts $zml/$xm/${i}.img
      if [ $info = "sparse" ]; then
        echo "[img]到[dat]:${i}.img"
        utils img2sdat $zml/$xm/${i}.img $zml/$xm/ 4 ${i}
        if [ -f $zml/$xm/${i}.new.dat ]; then
          [ $del = 1 ] && rm -rf $zml/$xm/${i}.img
        fi
      fi
      if [ $gs = br ]; then
        echo "[dat] to [br]: ${i}.new.dat"
        brotli -q $brlv -j -w 24 $zml/$xm/${i}.new.dat -o $zml/$xm/${i}.new.dat.br
        if [ -f $zml/$xm/${i}.new.dat.br ]; then
          [ $del = 1 ] && rm -rf $zml/$xm/${i}.new.dat
        fi
      fi
    fi
  done
}
warn() {
  echo "$1" >&2
}
download() {
  if [ -z $romdz ]; then
    warn "Please enter valid content"
    exit 1
  fi
  rname=$(basename $romdz)
  if [ -e $zml/${rname%?*} ]; then
    warn "You seem to have already downloaded this file"
    echo "Do you want to download again?"
    if pd; then
      rm -rf $zml/${rname%?*}
    else
      echo "Skip"
      [ $jb = 0 ] && exit 0
    fi
    if [ $jb = 1 ]; then
      echo "Do you want to unpack this file?"
      if pd; then
        xzrom=$zml/${rname%?*}
        UZ
      else
        echo "Skip unpacking"
        exit 0
      fi
    fi
  fi
  echo "Maximum speed enabled"
  curl -# -L -k $romdz -o $zml/${rname%?*}
  if [ $? = 1 ]; then
    error "Download failed"
    rm -rf $zml/${rname%?*}
  fi
  if [ $? = 0 ] && [ $jb = 1 ]; then
    xzrom=$zml/${rname%?*}
    UZ
  fi
}
error() {
  echo "$1 failed, please take a screenshot and contact developer Kamtena!" >&2
  exit 1
}
make_ext4() {
  [ ${img_type} = sparse ] && argv=-s
  make_ext4fs -J -T 1 $argv -S $con -l $size -C $fs -L $1 -a $1 $zml/$xm/$1.img $mdir/$xm/$1
  [ $? = 1 ] && error "packing"
  if [ $jxys = 1 ]; then
    if [ ${img_type} = raw ]; then
      resize2fs -M $zml/$xm/$1.img
    else
      warn "You have packed as sparse, cannot compress"
    fi
  fi
}
mkeimg() {
  size2=$(echo $size/4096 | bc | cut -d "." -f 1)
  bin/mke2fs -O ^has_journal -t ext4 -b 4096 -L $1 -I 256 -M /$1 $zml/$xm/$1.img $size2
  [ "$Reading" = "ro" ] && dx=-s
  bin/e2fsdroid -e -T 1230768000 -C $fs -S $con -f $mdir/$xm/$1 -a /$1 $dx $zml/$xm/$1.img
  if [ $? = 1 ]; then
    error "packing"
    rm -rf $zml/$xm/$1.img
  fi
  [ $jxys = 1 ] && resize2fs -M $zml/$xm/$1.img
  [ ${img_type} = sparse ] && rts $zml/$xm/$1.img
}
packsuper() {
  if [ "$type" = "A" ]; then
    command+="--metadata-size 65536 -super-name super -metadata-slots 2 -device super:${super_size} --group ${super_group}:${super_size} "
  fi
  for i in ${simg}; do
    [ "$(utils gettype $zml/$xm/${i}.img)" = "sparse" ] && str $zml/$xm/${i}.img
    if [ "$(utils gettype $zml/$xm/${i}.img)" = "erofs" ] || [ "$(utils gettype $zml/$xm/${i}.img)" = "ext" ]; then
      [ "$type" = "A" ] && command+="--partition ${i}:readonly:$(wc -c <$zml/$xm/${i}.img):${super_group} --image ${i}=$zml/$xm/${i}.img "
      if [ "$type" = "AB" ] || [ "$type" = "VAB" ]; then
        if [ ! -z $(echo ${i} | grep _a) ]; then
          ml1+="--partition ${i}_a:readonly:$(wc -c <$zml/$xm/${i}.img):${super_group} --image ${i}=$zml/$xm/${i}.img "
        else
          ml1+="--partition ${i}_a:readonly:$(wc -c <$zml/$xm/${i}.img):${super_group}_a --image ${i}_a=$zml/$xm/${i}.img "
        fi
        ml2+="--partition ${i}_b:readonly:0:${super_group}_b "
      fi
    fi
  done
  if [ "$type" = "AB" ] || [ "$type" = "VAB" ]; then
    command+="--metadata-size 65536 -super-name super -metadata-slots 3 -device super:${super_size} --group ${super_group}_a:${super_size} ${ml1} --group ${super_group}_b:${super_size} ${ml2} "
  fi
  [ "$type" = "VAB" ] && command+="--virtual-ab "
  [ "$from" = "sparse" ] && command+="--sparse "
  lpmake $command --out $zml/$xm/super.img
  if [ $? = 0 ]; then
    echo " - Packing successful!"
  else
    error " - packing super"
  fi
}
findfile() {
  for i in $(ls $zml/$xm/*.$1); do
    basename ${i} .$1
  done
}
readsize() {
  if [ -f $zml/$xm/dynamic_partitions_op_list ]; then
    list=$zml/$xm/dynamic_partitions_op_list
  else
    list=/dev/null
  fi
  if [ "$psize" = "auto" ]; then
    size=$(utils rsize $mdir/$xm/${1} 1 $list)
  else
    if [ -e $mdir/$xm/config/${1}_size.txt ]; then
      size=$(cat $mdir/$xm/config/${1}_size.txt)
    else
      warn "Image size configuration does not exist, switching to dynamic reading"
      size=$(utils rsize $mdir/$xm/${1} 1 $list)
    fi
    size=$(utils rsize $mdir/$xm/${1} 1 $list)
  fi
}
mkerofs() {
  mkfs.erofs -z${type},${fze} -T 1230768000 --mount-point=/$1 --fs-config-file=$fs --file-contexts=$con $zml/$xm/${i}.img $mdir/$xm/${i}
}
pack() {
  for i in ${UIMGS}; do
    xmdz=$(cat ${XBJ})
    if [ -e $mdir/$xm/config/${i}_info ]; then
      rboot $i
    fi
    fs=$mdir/$xm/config/"${i}"_fs_config
    con=$mdir/$xm/config/"${i}"_file_contexts
    utils patch_fs_con $mdir/$xm/${i} $fs $con
    echo " - Packing ${i}"
    readsize "${i}"
    if [ ! -f $mdir/$xm/config/${i}_erofs ]; then
      if [ "$zhua" != "1" ]; then
        $dbfs "${i}"
      else
        mkerofs "${i}"
      fi
    else
      if [ "$zhua" != "1" ]; then
        mkerofs "${i}"
      else
        $dbfs "${i}"
      fi
    fi
    if [ -f $zml/$xm/${i}.img ]; then
      echo " - Packing ${i} complete"
      [ $del = 1 ] && rm -rf $mdir/$xm/$i
    else
      [ $? = 1 ] && warn "Packing failed, source files not deleted"
    fi
  done
}
rts() {
  echo "[raw] to [sparse]: $(basename $1)"
  img2simg $1 $1_sparse
  [ -e "$1"_sparse ] && rm -rf $1
  mv "$1"_sparse $1
}
str() {
  echo "[sparse] to [raw]: $(basename $1)"
  utils simg2img "$1"
}
mn() {
  if [ -d $zml/"$xmmc" -o -d $mdir/"$xmmc" ]; then
    echo "- Project already exists, will be automatically renamed!"
    xmmc="$xmmc"-$(date "+%Y%m%d%H%M%S")
    echo "- Creating: ${xmmc}"
    mkdir -p $zml/"$xmmc"
    mkdir -p $mdir/"$xmmc"
  else
    echo "- Creating: ${xmmc}"
    mkdir -p $zml/"$xmmc"
    mkdir -p $mdir/"$xmmc"
  fi
  echo "- Creation complete!"
  echo ${xmmc} >${XBJ}
}
pd() {
  if [ $(id -u) = 0 ]; then
    echo "Volume key selection"
  else
    warn "You are using non-Root mode, default selection is No"
    return 1
    exit 0
  fi
  echo "[+]Yes [-]No"
  key=$(getevent -qlc 1)
  Up=$(echo $key | grep KEY_VOLUMEUP)
  Down=$(echo $key | grep KEY_VOLUMEDOWN)
  [ "$Up" != "" ] && return 0
  [ "$Down" != "" ] && return 1
}
install_module() {
  [ ! -d $START_DIR/module ] && mkdir -p $START_DIR/module
  utils zip_extract $zml/$xm/$file.mpk $START_DIR/module
  chmod -R 777 $START_DIR/module/
  for var in $(find $START_DIR/module/ -name install.sh); do
    source $var
    rm -rf $var
  done
}
finddir() {
  for i in $(ls -d $2/*/); do
    basename ${i}
  done
}
# View project
check() {
  for i in $(ls -d $zml/*/); do
    basename ${i}
  done
}
lsmdir() {
  for imgs in $(ls -d $mdir/$xm/*/); do
    [ -e $mdir/$xm/config/$(basename ${imgs})_file_contexts ] && basename ${imgs}
    [ -e $mdir/$xm/config/$(basename ${imgs})_info ] && basename ${imgs}
  done
}
zy() {
  if [ ! -d $zml/$xm ] || [ -z $xm ]; then
    echo "Please select a correct project"
  else
    echo "Current project: $zml/$xm"
  fi
}
unlock() {
  if [ ! -d $zml/$xm ] || [ -z $xm ]; then
    echo "Please reselect project"
  else
    echo 'unlocked'
  fi
}
# Delete project
del() {
  for i in ${xms}; do
    echo "- Deleting: ${i}"
    rm -rf $zml/${i}
    rm -rf $mdir/${i}
    echo "- Deletion of ${i} complete"
  done
}
UZ() {
  name=$(basename "$xzrom" .zip)
  if [ -d $zml/$name -o -d $mdir/$name ]; then
    mkdir -p $zml/$name
    mkdir -p $mdir/$name
  else
    mkdir -p $zml/$name
    mkdir -p $mdir/$name
  fi
  echo "- Starting to unpack $xzrom"
  utils zip_extract "$xzrom" $zml/$name
  echo "- Complete"
  echo $name >${XBJ}
  [ $del = 1 ] && rm -rf "$xzrom"
}
UN() {
  project=$zml/$xm/
  cd $project
  for i in $(ls *.* | cut -d "." -f 1); do
    ubdi ${i}
  done
  exit 0
}
delmod() {
  for i in ${mod}; do
    echo "Removing ${i}"
    [ -f $START_DIR/module/${i}/uninstall.sh ] && source $START_DIR/module/${i}/uninstall.sh
    rm -rf $START_DIR/module/${i}
    if [ "$?" == "0" ]; then
      echo "Deleted ${i}"
    else
      echo "Failed to delete ${i}"
    fi
  done
}
module() {
  cat <<Mod
<?xml version="1.0" encoding="utf-8"?>
<group reload="true">
    <action reload="true" auto-off="true">
        <title>Install Module</title>
        <set>script/tool.sh install_module</set>
        <param name="file" title="Please select module(s), multiple selection supported:" options-sh="script/tool.sh mpk" desc="Recognize files under MIO-Ultra project" required="true" multiple="true"/>
    </action>
    <action reload="true" auto-off="true">
        <title>Delete Module</title>
        <set>script/tool.sh delmod</set>
        <param name="mod" title="Please select module(s), multiple selection supported:" options-sh="script/tool.sh cm" desc="Recognize installed modules" required="true" multiple="true"/>
    </action>
</group>
<group title="Installed Modules">
Mod
  for var in $(find $START_DIR/module/ -name index.xml); do
    cat $var
  done

  cat <<Mod
</group>
Mod
}
zdyfj() {
  cd $zml/$xm/
  for i in ${IMG}; do
    info=$(utils gettype $i.img)
    image="${IMG}.img"
    if [ -e $mdir/$xm/config/${i}_file_contexts ]; then
      rm -rf $mdir/$xm/config/${i}_file_contexts
      rm -rf $mdir/$xm/config/${i}_fs_config
      rm -rf $mdir/$xm/config/${i}_size.txt
      rm -rf $mdir/$xm/${i}
    fi
    if [ -e $mdir/$xm/config/${i}_info ]; then
      rm -rf $mdir/$xm/config/${i}_info
      rm -rf $mdir/$xm/${i}
    fi
    uimg $i
  done
}
uimg() {
  if [ $info = "ext" ]; then
    echo "- Unpacking: $i.img [$info]"
    utils extract_ext $mdir/$xm/ $zml/$xm/$image
    exit 0
  elif [ $info = "erofs" ]; then
    echo "- Unpacking: ${i}.img [$info]"
    extract.erofs -i $zml/$xm/$image -o $mdir/$xm/ -x
    echo "erofs" >$mdir/$xm/config/${i}_erofs
    exit 0
  elif [ $info = sparse ]; then
    echo "- Converting: ${i} [sparse --> raw]"
    utils simg2img $image
    uimg $i
  elif [ "$info" = "super" ]; then
    echo "- Extracting: super.img"
    utils lpunpack $zml/$xm/$image $zml/$xm/
    exit 0
  elif [ "$info" = "boot" ]; then
    echo "- Unpacking: $i.img [$info]"
    mkdir -p $mdir/$xm/$i
    cd $mdir/$xm/$i
    cp -f $zml/$xm/$image $mdir/$xm/$i
    magiskboot unpack -h $image &>/dev/null
    if [ "$?" = "1" ]; then
      echo "- Failed!"
      rm -rf $mdir/$xm/$i
      continue
    else
      mkdir -p ramdisk
      chmod 777 ramdisk
      if [ -f ramdisk.cpio ]; then
        comp=$(magiskboot decompress ramdisk.cpio 2>&1 | grep -v 'raw' | sed -n 's;.*\[\(.*\)\];\1;p')
        if [ "$comp" ]; then
          mv -f ramdisk.cpio ramdisk.cpio.$comp
          magiskboot decompress ramdisk.cpio.$comp ramdisk.cpio 2>&1
          if [ $? != 0 ] && $comp --help 2>/dev/null; then
            $comp -dc ramdisk.cpio.$comp >ramdisk.cpio
          fi
        fi
        cd ramdisk
        EXTRACT_UNSAFE_SYMLINKS=1 cpio -d -F ../ramdisk.cpio -i 2>&1
        if [ $? != 0 -o ! "$(ls)" ]; then
          echo "- Failed!"
        else
          [ ! -d $mdir/$xm/config ] && mkdir -p $mdir/$xm/config
          echo $info >$mdir/$xm/config/"$i"_info
          echo $comp >>$mdir/$xm/config/"$i"_info
        fi
      else
        echo "- Ramdisk not found!"
      fi
    fi
  else
    echo "- Unpacking not supported: ${i}.img!"
  fi
}
rboot() {
  echo "- Starting to pack: ${i}.img"
  cd "$mdir/$xm/$i/ramdisk"
  find | sed 1d | cpio -H newc -R 0:0 -o -F ../ramdisk-new.cpio
  cd ..
  comp=$(sed -n '2p' "$mdir/$xm/config/${i}_info")
  if [ "$comp" ]; then
    magiskboot compress=$comp ramdisk-new.cpio 2>&1
    if [ "$fixb" = "1" ]; then
      echo "- Fix build"
      magiskboot cpio $$mdir/$xm/$i/ramdisk.cpio "extract prop.default prop.default"
      magiskboot cpio ramdisk.cpio "add 777 prop.default $$mdir/$xm/$i/prop.default"
      magiskboot cpio ramdisk.cpio "rm system/bin/variant-script.sh"
    fi
    if [ $? != 0 ] && $comp --help 2>/dev/null; then
      $comp -9c ramdisk-new.cpio >ramdisk.cpio.$comp
      if [ $? != 0 ]; then
        echo "Failed to repack ramdisk..."
        rm -f ramdisk-new.cpio
        break
      fi
    fi
  fi
  ramdisk=$(ls ramdisk-new.cpio* 2>/dev/null | tail -n1)
  if [ "$ramdisk" ]; then
    cp -f $ramdisk ramdisk.cpio
    case $comp in
    cpio) nocompflag="-n" ;;
    esac
    magiskboot repack $nocompflag ${i}.img $zml/$xm/${i}_new.img 2>&1
    echo "- Complete"
    exit 0
  fi
}
if (type $1 >/dev/null 2>&1); then
  $1
else
  findfile $1
fi
