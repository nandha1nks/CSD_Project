function main 3
int a
int b
int c
a = 1
b = 3
c = 2
c = a
_t1 = a == b
If _t1 goto _L0
pushParam a
pushParam c
_t5 = call func 2
a = _t5
goto _L1
_L0 :
_t2 = a + b
a = _t2
_t3 = b + c
_t4 = _t3 - a
b = _t4
_L1 :
end :
function func 0 int a int b
_t0 = a + b
return _t0
