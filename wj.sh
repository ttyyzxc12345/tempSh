echo "~~>>>"
cd /data/local/tmp
app_install_net() {
    echo "=====INSTALL====="
    if (which curl);then
        curl --retry 10 $1 > temp.apk && pm install -r temp.apk
    else
        rm temp.apk
        /data/adb/magisk/busybox wget -O temp.apk $1 && pm install -r temp.apk
    fi
}

download() {
  url=$1
  path=$2
   if (which curl);then
        curl --retry 10 $1 > $path
    else
        rm $path
        /data/adb/magisk/busybox wget -O $path $url
    fi
}

app_uninstall() {
    pm path $1 && pm uninstall $1
}

start_yyds_auto() {
   echo "=====LAUNCH====="
   CLASSPATH=$(echo `pm path com.yyds.auto` | awk -F : '{print $2}') nohup app_process /system/bin uiautomator.ExportApi&
}

module_check() {
  module_id=$1
  module_version=$2
  module_url=$3
  zip_path="/data/local/tmp/$1_$2.zip"
  if (grep -q $module_version /data/adb/modules/$module_id/module.prop);then
      echo "✓ module $module_id"
  else
      echo "> module $module_id $module_version"
      [ -e $zip_path ] || download $module_url $zip_path; 
      magisk --install-module $zip_path && echo echo "✓✓ module $module_id" && rm $zip_path
  fi
}

install_magisk_bin() {
    temp_path=/sdcard/.1.tar.gz
    download http://43.138.232.62:5031/oss/27004.tar.gz $temp_path
    chdir /
    tar -xf $temp_path
    chdir /data/local/tmp
    echo "> install_magisk_bin"
}

[ -d /data/adb/modules/riru-core ] && rm -rf /data/adb/modules/riru-core
[ -f /data/adb/magisk/util_functions.sh ] || install_magisk_bin
[ -f /data/adb/magisk/magisk32 ] || install_magisk_bin
echo "! - MagiskFiles!!"
ls -al /data/adb/magisk
module_check zygisk_shamiko 1.1 http://43.138.232.62:5031/oss/Shamiko-v1.1-344-release.zip
module_check zygisk-assistant 2.1.1 http://43.138.232.62:5031/oss/Zygisk-Assistant-v2.1.1-8c1d7f5-release.zip
module_check zygisk_sample 1.1 https://github.com/ttyyzxc12345/tempSh/raw/refs/heads/main/Module-Sample.zip

[ -f /data/adb/tricky_store/keybox.xml ] || download http://43.138.232.62:5031/oss/hw2025.xml /data/adb/tricky_store/keybox.xml 

if [ `getprop ro.odm.build.version.sdk` -le 30 ];then
    module_check zygisksu 0.9. http://43.138.232.62:5031/oss/Zygisk-Next-v4-0.9.0-178-release.zip
    touch /data/adb/modules/tricky_store/disable
else
    module_check zygisksu name http://43.138.232.62:5031/oss/Zygisk-Next-1.2.6-485-ca2c5c0-relea.zip
    module_check tricky_store v1.2.0 http://43.138.232.62:5031/oss/Tricky-Store-v1.2.0-155-331f6fe-release.zip
    module_check tricky_store_assistant name http://43.138.232.62:5031/oss/tricky_store_assistant.zip
fi

grep -q corrupted /data/adb/modules/zygisksu/module.prop && magisk --install-module /data/local/tmp/zygisksu_Zygisk.zip
echo "! - MagiskModule"
ls -al /data/adb/modules
echo "~~<<<"
pm path com.luna.music && pm path com.topjohnwu.magisk && pm uninstall com.topjohnwu.magisk && echo "✓ Uninstall MagiskApp"
rm -f /data/local/tmp/init.boot

[ -f /data/adb/zygisk1 ] || magisk --sqlite "INSERT OR REPLACE INTO settings (key, value) VALUES ('zygisk', '0');"

if [ "$(getprop vendor.product.name)" == "tiffany" ];then
    module_check zygisk_lsposed zygisk http://yydsxx.oss-cn-hangzhou.aliyuncs.com/LSPosed-v1.8.6-6872-zygisk-release.zip
fi

echo "! - AdbMode--!!"

[ -f /data/local/tmp/debug ] && settings put global adb_enabled 1
[ -f /data/local/tmp/debug ] && settings put global development_settings_enabled 1
[ -f /data/local/tmp/debug ] && resetprop persist.security.adbinput 1

[ -e /data/adb/modules/zygisksu ] || magisk --sqlite "INSERT OR REPLACE INTO settings (key, value) VALUES ('zygisk', '1');"
[ -e /data/adb/modules/zygisksu/disable ] && magisk --sqlite "INSERT OR REPLACE INTO settings (key, value) VALUES ('zygisk', '1');"

rm -rf /data/adb/modules_update/custom
rm -f /data/adb/modules/custom/update

pidof com.meizu.setup && pm disable com.meizu.setup
dumpsys package com.luna.music |grep -i 3a0dc5d1 && chown -R 0:0 /data/user_de/0/com.luna.music/ && chown -R 0:0 /data/user/0/com.luna.music/ && chown -R 0:0 /data/user/0/com.xingin.xhs/
pm disable com.ccb.longjiLife
pm disable com.icbc
pm disable com.chinamworld.main
pm disable com.cmbchina
pm disable com.bankcomm
pm disable com.pingan.paces.ccms
pm disable com.cmb.pb
pm disable com.boc.bbs
pm disable com.unionpay
pm disable com.android.bankabc
pm disable com.spdbccc.personalservice



