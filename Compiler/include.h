#include<bits/stdc++.h>

using namespace std;

typedef unsigned long long intl;

string output_file_name;

ofstream tac;


class func_sign{

    public:
    
    vector<string> params;
    vector<string> last_var;

};


class local{
    public:
    //          0 type    1 value  2 line 3 name  4 function_sign 5 current code  6 last variable  size
    vector<tuple<string , string , int , string ,   func_sign     , vector<string>  ,   string   ,  int> > node;
    unsigned long long int local_id;
    map<string , int> name2id;
    local();
};

local::local()
{
    local_id = 0;
}

//  name     id
map<string , int> name2id;
//           type     value    line  name     function_sign
vector<tuple<string , string , int , string , func_sign >> node;
unsigned long long global_id = 0;

unsigned long long label_id = 0;
unsigned long long t_id = 0;
unsigned long long dec_count = 0;

vector<string> complete_code;

string get_f(int id1, int id2, int id3)
{
    string s = "function ";

    s += get<3>(node[id1]);

    s += " 0";

    vector<string> v = get<4>(node[id2]).params;

    vector<string> u = get<4>(node[id3]).params;

    for(int i = v.size()-1 ; i >= 0 ; i--)
    {
        s += " ";
        s += u[i];
        s += " ";
        s += v[i];
    }

    return s;
}

string get_m(){
    string s = "function main ";

    return s;
}

string get_label()
{
    string s = "_L";
    s += to_string(label_id++);
    s += " :";
    return s;
}

string get_temp()
{
    string s = "_t";
    s += to_string(t_id++);
    return s;
}

stack<local> scope;

//unsigned long long int global_id = 0;
struct Snode{
        char type[31];
        int address;
        char lexval[32];
        float dval;
        int size;
        int isDval;
        int isArray;
};

void f1()
{
    ;
}

void check_type(local &l, int id1, int id2, function<void (void)> f1){
    string s1 = get<0>(l.node[id1]);
    string s2 = get<0>(l.node[id2]);
    if(s1 == s2){
        f1();
    }
    else{
        //cout<<get<3>(l.node[id1])<<":: "<<get<3>(l.node[id2])<<endl;;
        cout<<("Error - type " + s1 + " and type " + s2 + " don't match")<<endl;
        exit(0);
    }
}

void push_tuple(local &l){

    l.node.push_back(make_tuple("","",0,"",func_sign(),vector<string>(),"",0));
}

void push_tuple_global()
{
    node.push_back(make_tuple("","",0,"",func_sign()));

}

// not used
int get_next_id(){
    local l = scope.top();
    scope.pop();
    int ret = l.local_id++;
    scope.push(l);
    return ret;
}

// not used
void updated_type(int id1, int id2){
    local l = scope.top();
    get<0>(l.node[id1])=get<0>(l.node[id2]);
    scope.pop();
    scope.push(l);
}

void get_line(local& l, int id0, int id1, int id2, string op){

    string s;

    string new_temp = get_temp();

    s += (new_temp + " = " + get<6>(l.node[id1]) + " " + op + " " + get<6>(l.node[id2]));

    vector<string> temp = get<5>(l.node[id2]);

    temp.insert(temp.end(), get<5>(l.node[id1]).begin(), get<5>(l.node[id1]).end());

    temp.push_back(s);

    get<5>(l.node[id0]) = temp;

    get<6>(l.node[id0]) = new_temp;

}

void get_assgn(local& l, int id0, int id1, int id2)
{
    string s;

    s += (get<6>(l.node[id1]) + " = " + get<6>(l.node[id2]));

    vector<string> temp = get<5>(l.node[id2]);

    temp.push_back(s);

    get<5>(l.node[id0]) = temp;

    get<6>(l.node[id0]) = get<6>(l.node[id1]);
}

void get_assgn(local& l, int id0, int id1, int id2, int id3)
{
    string s;
    s = ("*(" + get<6>(l.node[id1]) + " + " + get<6>(l.node[id2]) + ")" + " = " + get<6>(l.node[id3]));

    vector<string> temp = get<5>(l.node[id3]);
    temp.insert(temp.end(), get<5>(l.node[id2]).begin(), get<5>(l.node[id2]).end());

    temp.push_back(s);

    get<5>(l.node[id0]) = temp;

    get<6>(l.node[id0]) = get<6>(l.node[id1]);
}

void get_line(local& l,int id0,int id1){
    get<6>(l.node[id0]) = get<6>(l.node[id1]);
    get<5>(l.node[id0]) = get<5>(l.node[id1]);
}

void print_code(){
    for(int i = 0; i < complete_code.size();i++){
        tac<<complete_code[i]<<endl;
    }
}

void get_line_func(local& l,int id0, int id1, int param){
    string s;
    string new_temp = get_temp();
    vector<string> temp = get<5>(l.node[param]);
    get<5>(l.node[id0]) = temp;
    //temp.insert(temp.end(), get<5>(l.node[id1]).begin(), get<5>(l.node[id1]).end());
    for(int i = 0; i<get<4>(l.node[param]).last_var.size();i++){
        s = ("pushParam " + get<4>(l.node[param]).last_var[i]);
        get<5>(l.node[id0]).push_back(s);
    }
    
    s = (new_temp + " = call " + get<3>(node[id1]) + " " + to_string(get<4>(l.node[param]).params.size()));
    get<5>(l.node[id0]).push_back(s);
    get<6>(l.node[id0]) = new_temp;
}

void get_line_param(local& l,int id0,int id1,int id2){
    vector<string> temp = get<5>(l.node[id1]);
    temp.insert(temp.end(), get<5>(l.node[id2]).begin(), get<5>(l.node[id2]).end());
    get<5>(l.node[id0]) = temp;
    get<4>(l.node[id2]).last_var.insert(get<4>(l.node[id2]).last_var.begin(),get<6>(l.node[id1]));
    get<4>(l.node[id0]) = get<4>(l.node[id2]);
    
}

