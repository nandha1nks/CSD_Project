#include <bits/stdc++.h>
using namespace std;

/*
    Token Type:
        temp variable: _t0, _t1, _t2
        variable: x,y,z
        int constant: 1,20,300
        ADD: +
        SUB: -
        MUL: *
        DIV: /
        MOD: %
        Assignment: =
        EOL: ;
*/

class Token {
    private:
        string getType(string);
    public:
        string name;
        string type;
        Token(string);
};

Token::Token(string s) {
    name = s;
    // type = getType(s);
}