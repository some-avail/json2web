import std/[times,strutils, os]


template withFile*(f, fn, mode, actions: untyped): untyped =
  var f: File
  if open(f, fn, mode):
    try:
      actions
    finally:
      close(f)
  else:
    quit("cannot open: " & fn)


#[ 
Below are some timing-functions that may or may not
work. I find the cpuTime function unreliable, for example
it doesnt register a sleep-function. 
Finally in timeCop i revert to the now-function, which seems
accurate.
 ]#



proc doWork(x: int) =
  var n = 0
  for i in 0 .. 10000000 * x:
    n += i


template timeStuff*(statement: untyped): string =
  let t0 = cpuTime()
  statement
  formatFloat(cpuTime() - t0, ffDecimal, precision = 3)


template timeThings*(statement: untyped) =
  # easiest to use
  let t0 = cpuTime()
  statement
  echo formatFloat(cpuTime() - t0, ffDecimal, precision = 3), " s."



template timeNeatly(statement: untyped): float =
  let t0 = cpuTime()
  statement
  cpuTime() - t0


template  timeCop*(statement: untyped) = 
  let t0 = now()
  statement
  let t1 = now()
  echo t1 - t0




when isMainModule:
  #[ 
  withFile(txt, "test_templ.txt", fmWrite):  # special colon
    txt.writeLine("line 1")
    txt.writeLine("line 2")
 ]#
  
  #echo "Time = ", timeStuff(doWork(100)), " s"
  #echo "Time = ", timeNeatly(sleep(2000)).formatFloat(ffDecimal, precision = 3), " s"

#[ 
  let t0 = cpuTime()
  echo t0
  #sleep(2000)
  doWork(10)
  let t1 = cpuTime()
  echo t1
  echo t1 - t0
  echo formatFloat(t1 - t0, ffDecimal, precision = 3), " s."
 ]#

#[ 
  let t0 = now()
  echo t0
  sleep(2000)
  #doWork(10)
  let t1 = now()
  echo t1
  echo t1 - t0
  #echo formatFloat(t1 - t0, ffDecimal, precision = 3), " s."
 ]#


  timeCop():
    #doWork(10)
    sleep(2000)
