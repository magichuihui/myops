#!/bin/bash
#rsync auto sync script with inotify
#2014-12-11 Sean
#variables
current_date=$(date +%Y%m%d_%H%M%S)
source_path=/data/htdocs/www/baiyang/static/subject/
log_file=/var/log/rsync_client.log
#rsync
rsync_server=${RSYNCD_SERVER}
rsync_user=backup
rsync_pwd=/etc/rsyncd.pass
rsync_module=baiyang_subject
#rsync client pwd check
if [ ! -e ${rsync_pwd} ];then
    echo -e "rsync client passwod file ${rsync_pwd} does not exist!"
    exit 0
fi
#inotify_function
inotify_fun(){
    /usr/bin/inotifywait -mrq --timefmt '%Y/%m/%d-%H:%M:%S' --format '%T %w %f' \
           -e modify,delete,create,move,attrib ${source_path} \
          | while read file
      do
          /usr/bin/rsync -auvrtzopgP --delete --progress --bwlimit=200 --password-file=${rsync_pwd} ${source_path} ${rsync_user}@${rsync_server}::${rsync_module}
      done
}
#inotify log
inotify_fun >> ${log_file} 2>&1 &

