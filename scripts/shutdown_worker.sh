#!/bin/sh
# set -ve

# This shell script supports 3 different termination modes for k8s pre-stop hook.
# 1. einhorn graceful rolling termination, it's sidekiq enterprise feature (best way)
# 2. graceful termination by checking sidekiq alive busy count http endpoint (efficient way)
# 3. original termination by executing sidekiq rake script (expensive way)

MAX_WAIT_TIME=600
START_TIME=$(date +%s)
END_TIME=$(( $(date +%s) + MAX_WAIT_TIME ))

# check if sidekiq process terminated
sidekiq_process_terminated() {
  SIDEKIQ_PID=$(ps aux | grep sidekiq | grep busy | awk '{ print $2 }')
  if [ "x$SIDEKIQ_PID" != "x" ]; then
    return 1
  fi
  return 0
}

# check if sidekiq busy count feature enabled
sidekiq_busy_count_enabled() {
  http_status="$(curl -s -o /dev/null -w "%{http_code}" http://localhost:7433/busy_count)"
  retval=$?

  if [ $retval -ne 0 ] || [ $http_status -ne 200 ]; then
    return 1
  fi
  return 0
}

# check if sidekiq workers still busy
sidekiq_not_busy() {
  busy_count="$(curl -s http://localhost:7433/busy_count)"
  retval=$?

  # return true if fail to access sidekiq busy http endpoint
  if [ $retval -ne 0 ]; then
    echo "retval=$retval"
    return 0
  fi


  # return false if busy count not equal to zero
  if [ "$busy_count" != "0" ]; then
    return 1
  fi
  return 0
}

# search sidekiq process and send TSTP signal to quiet it
quiet_sidekiq_process() {
  # Send TSTP to sidekiq so that it stops taking in new jobs
  TINI_PID=$(ps aux | egrep "[t]ini.*sidekiq" | awk '{ print $2 }')
  if [ "x$TINI_PID" != "x" ]; then
      echo "Send TSTP signal to tini, pid $TINI_PID"
    kill -s TSTP $TINI_PID
    return 0
  else
    SIDEKIQ_PID=$(ps aux | egrep ".*[s]idekiq.*busy" | awk '{ print $2 }')
    if [ "x$SIDEKIQ_PID" != "x" ]; then
      echo "Send TSTP signal to sidekiq, pid $SIDEKIQ_PID"
      kill -s TSTP $SIDEKIQ_PID
      return 0
    fi
  fi
  return 1
}

wait_sidekiq_job_finished() {
  sleep $1
  wait_secs=$(( $(date +%s) - START_TIME ))
  echo "Wait for all sidekiq jobs to finish, $wait_secs seconds"
}

# Shutdown procedures
echo 'Sidekiq Shutdowning'

# graceful terminate sidekiq enterprise by einhornsh, it's enterprise version feature
EINHORN_PID=$(ps aux | egrep "[e]inhorn.*sidekiq" | awk '{ print $2 }')
if [ "x${EINHORN_PID}" != "x" ]; then
  echo "Terminate sidekiq process by einhorn"
  einhornsh --execute die || exit 1

  until [ $(date +%s) -gt $END_TIME ] || sidekiq_process_terminated; do
    wait_sidekiq_job_finished 2
  done

# graceful terminate sidekiq by checking busy count http endpoint (sidekiq-alive)
elif sidekiq_busy_count_enabled; then
  echo "Quiet sidekiq process by checking busy count http endpoint"
  quiet_sidekiq_process || exit 1

  # wait 6 seconds for sidekiq to update process busy count. Sidekiq update process info every 5 secs.
  # https://github.com/mperham/sidekiq/wiki/API#processes
  sleep 6

  until [ $(date +%s) -gt $END_TIME ] || sidekiq_not_busy ; do
    wait_sidekiq_job_finished 5
  done

  # Don't send TERM signal to sidekiq process here, this script is invoked by k8s PreStop hook

else # original expensive terminate process
  echo "Quiet sidekiq process by sidekiq rake script"
  [ -d /myapp ] && cd /myapp
  # Send TSTP to tini so that it stops taking in new jobs
  quiet_sidekiq_process || exit 1

  # wait 6 seconds for sidekiq to update process busy count. Sidekiq update process info every 5 secs.
  # https://github.com/mperham/sidekiq/wiki/API#processes
  sleep 6

  until [ $(date +%s) -gt $END_TIME ] || bundle exec rails sidekiq:busy ; do
    wait_sidekiq_job_finished 5
  done

  # Don't send TERM signal to sidekiq process here, this script is invoked by k8s PreStop hook
fi

echo 'Sidekiq Shutdowned'
