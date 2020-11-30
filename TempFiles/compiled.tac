function main 1
int a
read a
pushParam a
_t7 = call fib 1
print _t7
end :
function fib 0 int n
_t0 = n < 2
If _t0 goto _L0
_t3 = n - 2
pushParam _t3
_t4 = call fib 1
_t1 = n - 1
pushParam _t1
_t2 = call fib 1
_t5 = _t2 + _t4
_t6 = _t5
goto _L1
_L0 :
_t6 = n
_L1 :
return _t6
