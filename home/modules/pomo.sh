#!/usr/bin/env bash

function now(){
  date +%s
}


function save_state(){
  # Save timer state to file
  echo "current_cycle=$current_cycle" > $state_file
  echo "time_started=$time_started" >> $state_file
  echo "cycle_count=$cycle_count" >> $state_file
}

function next_cycle() {
  case $current_cycle in
    idle)
      time_started=$(now)
      current_cycle=work
    ;;
  short)
      if [ $finished = true ]; then
        time_started=$(now)
        current_cycle=work
      fi
    ;;
  long)
      if [ $finished = true ]; then
        time_started=$(now)
        current_cycle=work
      fi
    ;;
  work)
    cycle_count=$((cycle_count + 1))
    if [ $finished = true ]; then
      if [[ $cycle_count -eq $num_work_cycles ]]; then
        cycle_count=0
        current_cycle=long
      else
        current_cycle=short
      fi
      time_started=$(now)
    fi
    ;;
  *)
    cycle_count=0
    current_cycle=idle
    time_started=$(now)
    ;;
  esac
}

function pomo_start(){
  old_cycle=$current_cycle
  next_cycle
  save_state
  if [[ $old_cycle = $current_cycle ]]; then
    echo "Still $current_cycle"
  else
    echo "Starting $current_cycle"
  fi
}

function pomo_skip(){
  old_cycle=$current_cycle
  # skipping as if we'd finished this one
  finished=true
  next_cycle
  save_state
  if [[ $old_cycle = $current_cycle ]]; then
    echo "Still $current_cycle"
  else
    echo "Starting $current_cycle"
  fi
}

function pomo_restart(){
  time_started=$(now)
  save_state
}

function pomo_reset(){
  cycle_count=0
  time_started=0
  current_cycle=idle
  save_state
}

function pomo_remaining() {
  duration=${current_cycle}_duration
  time_finished=$((time_started + duration))
  n=$(now)
  remaining=$((time_finished - n))
  if [[ $remaining -lt 0 ]]; then
    remaining=0
  fi
  if [[ -z $1 ]]; then
    echo $remaining
  else
    date -d "@$remaining" $1
  fi
}

function pomo_cycle() {
  echo $current_cycle
}

function pomo_count() {
  echo $cycle_count
}

function pomo_percent() {
  remaining=$(pomo_remaining)
  duration=${current_cycle}_duration
  frac=$((remaining * 100 / duration * 100))
  perc=$((100 - frac / 100))
  echo $perc
}

function pomo_config() {
  echo "work_duration=$work_duration"
  echo "short_duration=$short_duration"
  echo "long_duration=$long_duration"
  echo "num_work_cycles=$num_work_cycles"
}

function usage() {
  echo "Usage: $0 <start|restart|skip|reset|remaining|cycle|count|percent>"
  exit 1
}

# state is stored in a pomo file
state_dir="$HOME/.local/share/"
state_file="$state_dir/pomo"

# Define cycle durations in seconds
work_duration=$((30 * 60))
short_duration=$((5 * 60))
long_duration=$((15 * 60))
num_work_cycles=4

# Initialize variables
current_cycle=idle
time_started=0
cycle_count=0

# Check if the timer state file exists
if [ -f $state_file ]; then
  # Load state from file
  current_cycle=$(cat $state_file | grep 'current_cycle=' | cut -d '=' -f2 | tr -d ' ')
  time_started=$(cat $state_file | grep 'time_started=' | cut -d '=' -f2 | tr -d ' ')
  remaining=$(pomo_remaining)
  if [[ $remaining -gt 0 ]]; then
    finished=false
  else
    finished=true
  fi
  cycle_count=$(cat $state_file | grep 'cycle_count=' | cut -d '=' -f2 | tr -d ' ')
fi

if [[ -z $1 ]]; then
  echo "No command given"
  usage
else
  cmd=$1
  shift
  pomo_$cmd $@
fi
