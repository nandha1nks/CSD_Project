%{
    #include"include.h"

    using namespace std;

    extern FILE * yyin;

    int yylex();    
    int yyerror(char* s);
    

%}

%union {
    char dval[32];
    char lexeme[32];
    char type[31];
    struct Snode *snode;
    unsigned long long int id;
}

%token OCB CCB OSB CSB ASG SCL COM PTR DT ID NUM PLS MIN FSH BSH PCT LOR LAND BOR BAND BXOR EQL NEQL GT LT GTE LTE OB CB QM CL STR BLK MN IF ELS FN OS PRT GIN

%type <dval> NUM
%type <lexeme> ID
%type <id> main
%type <id> function_def
%type <id> io_statement
%type <id> io_statements
%type <id> statement
%type <id> expression
%type <id> block
%type <id> additive_expression
%type <id> multiplicative_expression
%type <id> assignment_statement
%type <id> selection_statement
%type <id> relational_expression
%type <id> equality_expression
%type <id> identifier
%type <id> function_call
%type <id> declaration_statement
%type <type> DT
%type <id> and_expression
%type <id> or_expression
%type <id> parameter_list
%type <id> parameter_lists
%type <id> function_declaration
%type <id> pram_list 
%type <id> pram_lists 
%type <id> param_def
%type <id> param_defs 
%type <id> output_statement
%type <id> input_statement
%type <id> OS

%%
program:                upper_chunk main{print_code();};

upper_chunk:            function_declaration function_def upper_chunk
			            |
                        ;

function_declaration:    DT ID OB pram_list CB SCL {$$ = $4 ; string temp = $1 ;get<0>(node[$$]) = temp; string temp2 = $2; if(name2id.find(temp2) == name2id.end()){
                                                                                                                                                                                get<3>(node[$$]) = temp2;
                                                                                                                                                                                name2id[temp2] = $$;  
                                                                                                                                                                        }
                                                                                                                               else{
                                                                                                                                   cout <<"Error- name already used!!"<< endl;
                                                                                                                                   exit(0);
                                                                                                                               }                                        
                                                                                                                                                                        };

function_def:    ID OB param_def CB OCB {local l;string temp = $1; if(name2id.find(temp) == name2id.end())
                                                                                        {
                                                                                            cout <<"Error- function " << temp << " not declared!!" << endl;
                                                                                            exit(0);
                                                                                        }
                                                                                      else
                                                                                      {
                                                                                          if((get<4>(node[name2id[temp]]).params).size() != (get<4>(node[$3]).params).size())
                                                                                          {
                                                                                              cout << "Error - worng number of arguments" << endl;
                                                                                          }
                                                                                          else
                                                                                          {
                                                                                              vector<string> name_1 = get<4>(node[$3]).params;
                                                                                              vector<string> type_1 = get<4>(node[name2id[temp]]).params;

                                                                                              for(intl i = 0 ; i < name_1.size() ; ++i)
                                                                                              {
                                                                                                  int temp_id = l.local_id++;
                                                                                                  push_tuple(l);

                                                                                                  get<3>(l.node[temp_id]) = name_1[i];
                                                                                                  get<0>(l.node[temp_id]) = type_1[i];

                                                                                                  l.name2id[name_1[i]] = temp_id;
                                                                                              }

                                                                                              
                                                                                              //complete_code.push_back(get_label());              
                                                                                              complete_code.push_back(get_f(name2id[$1] , $3,name2id[temp]));
                                                                                          }
                                                                                        }
                                                                                        scope.push(l);
                                                                                        
                                                                                        }   expression {local l = scope.top(); scope.pop();get<5>(l.node[$7]).push_back("return " + get<6>(l.node[$7]));complete_code.insert(complete_code.end(), get<5>(l.node[$7]).begin(), get<5>(l.node[$7]).end());} CCB {string temp = $1;$$ = name2id[temp];};

pram_list:             pram_lists {$$ = $1;}
                        | {$$ = global_id++;push_tuple_global();}
                        ;

pram_lists:             DT COM pram_lists {$$ = $3 ; string temp = $1 ;(get<4>(node[$$]).params).push_back(temp);}
                        | DT {$$ = global_id++;push_tuple_global(); string temp = $1; (get<4>(node[$$]).params).push_back(temp);}
                        ;

param_def:              param_defs {$$ = $1;}
                        | {$$ = global_id++;push_tuple_global();}
                        ;

param_defs:             ID COM param_defs {$$ = $3 ; string temp = $1 ;(get<4>(node[$$]).params).push_back(temp);}
                        | ID {$$ = global_id++;push_tuple_global(); string temp = $1 ;(get<4>(node[$$]).params).push_back(temp);}
                        ;

//main function , point where program starts to run
main:                   MN OB CB OCB {local l;complete_code.insert(complete_code.begin(),"end :");complete_code.insert(complete_code.begin(),get_m()); scope.push(l);}io_statements CCB {local l = scope.top();scope.pop();complete_code[0] += to_string(dec_count);complete_code.insert(complete_code.begin() + 1, get<5>(l.node[$6]).begin(), get<5>(l.node[$6]).end());};

// io_statement -> IO
io_statements:          statement{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);get_line(l,$$,$1);scope.push(l);}
                        | io_statements statement{local l = scope.top();scope.pop();$$ = $1;get<5>(l.node[$1]).insert(get<5>(l.node[$1]).end(), get<5>(l.node[$2]).begin(), get<5>(l.node[$2]).end());scope.push(l);};
// statement -> IO    
statement:              io_statement SCL{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);get<0>(l.node[$$])="io";get_line(l,$$,$1);scope.push(l);}
                        | selection_statement{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);get<0>(l.node[$$])="io";check_type(l,$1,$$,f1);get_line(l,$$,$1);scope.push(l);};

// selection_statement -> expression
selection_statement:    IF OB or_expression CB OCB or_expression CCB ELS OCB or_expression CCB{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);check_type(l,$10,$6,f1);get<0>(l.node[$$])=get<0>(l.node[$6]);
                                                                                            if(get<0>(l.node[$6]) != "io"){
                                                                                                get<5>(l.node[$$]) = get<5>(l.node[$3]);
                                                                                                get<5>(l.node[$$]).push_back("If " + get<6>(l.node[$3]) + " goto " + "_L" + to_string(label_id));
                                                                                                get<5>(l.node[$$]).insert(get<5>(l.node[$$]).end(), get<5>(l.node[$10]).begin(), get<5>(l.node[$10]).end());
                                                                                                get<5>(l.node[$$]).push_back("_t"+to_string(t_id)+" = "+get<6>(l.node[$10]));
                                                                                                string if_label = get_label();
                                                                                                get<5>(l.node[$$]).push_back("goto _L" + to_string(label_id));
                                                                                                get<5>(l.node[$$]).push_back(if_label);
                                                                                                get<5>(l.node[$$]).insert(get<5>(l.node[$$]).end(), get<5>(l.node[$6]).begin(), get<5>(l.node[$6]).end());
                                                                                                get<5>(l.node[$$]).push_back("_t" + to_string(t_id) + " = " + get<6>(l.node[$6]));
                                                                                                get<5>(l.node[$$]).push_back(get_label());
                                                                                                get<6>(l.node[$$]) = get_temp();
                                                                                            }
                                                                                            else
                                                                                            {
                                                                                                get<5>(l.node[$$]) = get<5>(l.node[$3]);
                                                                                                get<5>(l.node[$$]).push_back("If " + get<6>(l.node[$3]) + " goto " + "_L" + to_string(label_id));
                                                                                                get<5>(l.node[$$]).insert(get<5>(l.node[$$]).end(), get<5>(l.node[$10]).begin(), get<5>(l.node[$10]).end());
                                                                                                string if_label = get_label();
                                                                                                get<5>(l.node[$$]).push_back("goto _L" + to_string(label_id));
                                                                                                get<5>(l.node[$$]).push_back(if_label);
                                                                                                get<5>(l.node[$$]).insert(get<5>(l.node[$$]).end(), get<5>(l.node[$6]).begin(), get<5>(l.node[$6]).end());
                                                                                                get<5>(l.node[$$]).push_back(get_label());
                                                                                            }
                                                                                            scope.push(l);};

// or_expression -> bool
or_expression:          and_expression{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);get<0>(l.node[$$])=get<0>(l.node[$1]);get_line(l,$$,$1);scope.push(l);}
                        | and_expression LOR or_expression{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);check_type(l,$1,$3,f1);get<0>(l.node[$$])=get<0>(l.node[$1]);get_line(l,$$,$1,$3,"||");scope.push(l);};

// and_expression -> bool                        
and_expression:         equality_expression {local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);get<0>(l.node[$$])=get<0>(l.node[$1]);get_line(l,$$,$1);scope.push(l);}
                        | equality_expression LAND and_expression{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);check_type(l,$1,$3,f1);get<0>(l.node[$$])=get<0>(l.node[$1]);get_line(l,$$,$1,$3,"&&");scope.push(l);};

// equality_expression -> bool
equality_expression:    relational_expression{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);get<0>(l.node[$$])=get<0>(l.node[$1]);get_line(l,$$,$1);scope.push(l);}
                        | relational_expression EQL equality_expression{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);check_type(l,$1,$3,f1);get<0>(l.node[$$])=get<0>(l.node[$1]);get_line(l,$$,$1,$3,"==");scope.push(l);}
                        | relational_expression NEQL equality_expression{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);check_type(l,$1,$3,f1);get<0>(l.node[$$])=get<0>(l.node[$1]);get_line(l,$$,$1,$3,"!=");scope.push(l);};
                        //| expression EQL expression{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);check_type(l,$1,$3,f1);get<0>(l.node[$$])=get<0>(l.node[$1]);scope.push(l);}
                        //| expression NEQL expression{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);check_type(l,$1,$3,f1);get<0>(l.node[$$])=get<0>(l.node[$1]);scope.push(l);};

// relational_expression -> bool
relational_expression:  expression{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);get<0>(l.node[$$])=get<0>(l.node[$1]);get_line(l,$$,$1);scope.push(l);}
                        | expression LT expression{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);check_type(l,$1,$3,f1);get<0>(l.node[$$])=get<0>(l.node[$1]);get_line(l,$$,$1,$3,"<");scope.push(l);}
                        | expression GT expression{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);check_type(l,$1,$3,f1);get<0>(l.node[$$])=get<0>(l.node[$1]);get_line(l,$$,$1,$3,">");scope.push(l);}
                        | expression LTE expression{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);check_type(l,$1,$3,f1);get<0>(l.node[$$])=get<0>(l.node[$1]);get_line(l,$$,$1,$3,"<=");scope.push(l);}
                        | expression GTE expression{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);check_type(l,$1,$3,f1);get<0>(l.node[$$])=get<0>(l.node[$1]);get_line(l,$$,$1,$3,">=");scope.push(l);};


// io_statement -> IO
io_statement:           assignment_statement{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);get<0>(l.node[$$])=get<0>(l.node[$1]);get_line(l,$$,$1);scope.push(l);}
                        | block{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);get<0>(l.node[$$])=get<0>(l.node[$1]);get_line(l,$$,$1);scope.push(l);}
                        | declaration_statement{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);get<0>(l.node[$$])=get<0>(l.node[$1]);get_line(l,$$,$1);scope.push(l);}
                        | output_statement{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);get<0>(l.node[$$])=get<0>(l.node[$1]);get_line(l,$$,$1);scope.push(l);}
                        | input_statement{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);get<0>(l.node[$$])=get<0>(l.node[$1]);get_line(l,$$,$1);scope.push(l);};

declaration_statement:  DT ID {
                                local l = scope.top();
                                scope.pop();$$ = l.local_id++;
                                push_tuple(l);get<0>(l.node[$$])="io";
                                int temp = l.local_id++;
                                push_tuple(l);
                                string s2 = $2;
                                string s1 = $1;
                                l.name2id[s2] = temp;
                                get<6>(l.node[temp]) = s2;
                                get<0>(l.node[temp]) = s1; 
                                get<3>(l.node[temp]) = s2;
                                get<5>(l.node[$$]).push_back(s1 + " " + s2);
                                scope.push(l); 
                                dec_count++;
                                };
                        | DT ID OSB expression CSB{
                                local l = scope.top();
                                scope.pop();$$ = l.local_id++;
                                push_tuple(l);get<0>(l.node[$$])="io";
                                int temp = l.local_id++;
                                push_tuple(l);
                                string s2 = $2;
                                string s1 = $1;
                                l.name2id[s2] = temp;
                                get<6>(l.node[temp]) = s2;
                                get<0>(l.node[temp]) = s1; 
                                get<3>(l.node[temp]) = s2;
                                get<5>(l.node[$$]) = get<5>(l.node[$4]);
                                get<5>(l.node[$$]).push_back("array " + s1 + " " + s2 + " " + get<6>(l.node[$4]));
                                scope.push(l); 
                                dec_count++;
                                };

// assignment_statement -> IO
assignment_statement:   ID ASG expression{local l = scope.top();scope.pop();
                                            $$ = l.local_id++;
                                            push_tuple(l);
                                            get<0>(l.node[$$])="io";
                                            string tmp = $1; 
                                            if(l.name2id.find(tmp) == l.name2id.end()){
                                                cout << "Variable not declared!!" << endl;
                                                exit(0);
                                            }
                                            get_assgn(l,$$,l.name2id[$1],$3);
                                        scope.push(l);}
                        | ID OSB expression CSB ASG expression{local l = scope.top();scope.pop();
                                            $$ = l.local_id++;
                                            push_tuple(l);
                                            get<0>(l.node[$$])="io";
                                            string tmp = $1; 
                                            if(l.name2id.find(tmp) == l.name2id.end()){
                                                cout << "Variable not declared!!" << endl;
                                                exit(0);
                                            }
                                            get_assgn(l,$$,l.name2id[$1],$3,$6);
                                        scope.push(l);};

// output_statement -> IO
output_statement:       PRT OB expression CB{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);get<0>(l.node[$$])="io";get_line(l,$$,$3);get<5>(l.node[$$]).push_back("print " + get<6>(l.node[$3]));scope.push(l);};

// input_statement -> IO
input_statement:       GIN OB ID CB{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);get<0>(l.node[$$])="io";int id = l.name2id[$3];get_line(l,$$,id);get<5>(l.node[$$]).push_back("read " + get<6>(l.node[id]));scope.push(l);};

// block -> IO
block:                  BLK OCB io_statements CCB{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);get<0>(l.node[$$])="io";get_line(l,$$,$3);scope.push(l);};


expression:             
                         io_statement SCL {local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);get<0>(l.node[$$])=get<0>(l.node[$1]);get_line(l,$$,$1);scope.push(l);}
                        | selection_statement{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);get<0>(l.node[$$])=get<0>(l.node[$1]);get_line(l,$$,$1);scope.push(l);}
                        | additive_expression{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);get<0>(l.node[$$])=get<0>(l.node[$1]);get_line(l,$$,$1);scope.push(l);}
                        ;

additive_expression:    multiplicative_expression{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);get<0>(l.node[$$])=get<0>(l.node[$1]);get<6>(l.node[$$])=get<6>(l.node[$1]);get_line(l,$$,$1);scope.push(l);}
                        | additive_expression PLS multiplicative_expression{local l = scope.top();scope.pop();check_type(l,$1,$3,f1); $$ = l.local_id++;push_tuple(l);get<0>(l.node[$$])=get<0>(l.node[$1]);get_line(l,$$,$1,$3,"+");scope.push(l);}
                        | additive_expression MIN multiplicative_expression{local l = scope.top();scope.pop();check_type(l,$1,$3,f1); $$ = l.local_id++;push_tuple(l);get<0>(l.node[$$])=get<0>(l.node[$1]);get_line(l,$$,$1,$3,"-");scope.push(l);};

multiplicative_expression:  identifier{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);get<0>(l.node[$$])=get<0>(l.node[$1]);get_line(l,$$,$1);scope.push(l);}
                            | multiplicative_expression STR identifier{local l = scope.top();scope.pop();check_type(l,$1,$3,f1);$$ = l.local_id++;push_tuple(l);get<0>(l.node[$$])=get<0>(l.node[$1]);get_line(l,$$,$1,$3,"*");scope.push(l);} 
                            | multiplicative_expression FSH identifier{local l = scope.top();scope.pop();check_type(l,$1,$3,f1);$$ = l.local_id++;push_tuple(l);get<0>(l.node[$$])=get<0>(l.node[$1]);get_line(l,$$,$1,$3,"/");scope.push(l);}
                            | multiplicative_expression PCT identifier{local l = scope.top();scope.pop();check_type(l,$1,$3,f1);$$ = l.local_id++;push_tuple(l);get<0>(l.node[$$])=get<0>(l.node[$1]);get_line(l,$$,$1,$3,"%");scope.push(l);};

identifier:             NUM{local l = scope.top();scope.pop();
                            $$ = l.local_id++;
                            push_tuple(l);
                            string tmp = $1;
                            get<1>(l.node[$$]) = tmp;
                            get<0>(l.node[$$]) = "int";
                            get<6>(l.node[$$]) = tmp;
                            scope.push(l);}
                        | ID{
                                local l = scope.top();scope.pop();
                                string tmp = $1;
                                if(l.name2id.find(tmp) == l.name2id.end()){
                                    cout << "Variable not declared!!" << endl;
                                    exit(0);
                                }
                                else
                                {
                                    $$ = l.local_id++;
                                    push_tuple(l);
                                    l.node[$$] = l.node[l.name2id[tmp]];
                                }
                                get<6>(l.node[$$]) = tmp;
                                scope.push(l);
                            }
                        | ID OSB expression CSB{
                                local l = scope.top();scope.pop();
                                string tmp = $1;
                                if(l.name2id.find(tmp) == l.name2id.end()){
                                    cout << "Variable not declared!!" << endl;
                                    exit(0);
                                }
                                else
                                {
                                    $$ = l.local_id++;
                                    push_tuple(l);
                                    l.node[$$] = l.node[l.name2id[tmp]];
                                }
                                string s = get_temp();
                                get<5>(l.node[$$]) = get<5>(l.node[$3]);
                                get<5>(l.node[$$]).push_back(s + " = *(" + $1 + " + " + get<6>(l.node[$3]) + ")");
                                get<6>(l.node[$$]) = s;
                                scope.push(l);
                            };
                            | function_call{local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);get<0>(l.node[$$])=get<0>(l.node[$1]);get_line(l,$$,$1);scope.push(l);}

function_call:          ID OB parameter_list CB {local l = scope.top();scope.pop();
                                                    $$ = l.local_id++;
                                                    push_tuple(l);
                                                    string s = $1;
                                                    int t = name2id[s];
                                                    get<0>(l.node[$$])=get<0>(node[t]);
                                                    string tmp = $1;
                                                    if(name2id.find(tmp) == name2id.end()){
                                                        cout << "Function not declared!!" << endl;
                                                        exit(0);
                                                    }
                                                    string tmp1 = $1;
                                                    int id1 = name2id[tmp1];
                                                    int id2 = $3;
                                                    func_sign f = get<4>(node[id1]);
                                                    func_sign pm = get<4>(l.node[id2]);
                                                    if(f.params.size() != pm.params.size()){
                                                        cout<< "Invalid Parameters!!" << endl;
                                                        exit(0);
                                                    }
                                                    for(int i = 0; i < f.params.size(); i++){
                                                        if(f.params[i] != pm.params[i]){
                                                            cout<< "Invalid Parameters!!" << endl;
                                                            exit(0);
                                                        }
                                                    }
                                                    get_line_func(l,$$,t,$3);
                                                    
                        scope.push(l);};

parameter_list:         parameter_lists {local l = scope.top();scope.pop();$$ = $1;get_line(l,$$,$1);scope.push(l);}
                        | {local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l);scope.push(l);}   
                        ;

parameter_lists:        expression COM parameter_lists {local l = scope.top();scope.pop();$$ = $3 ; string temp = get<0>(l.node[$1]);(get<4>(l.node[$$]).params).push_back(temp);get_line_param(l,$$,$1,$3);scope.push(l);}
                        | expression {local l = scope.top();scope.pop();$$ = l.local_id++;push_tuple(l); string temp = get<0>(l.node[$1]);(get<4>(l.node[$$]).params).push_back(temp);get<4>(l.node[$$]).last_var.insert(get<4>(l.node[$$]).last_var.begin(),get<6>(l.node[$1]));get_line(l,$$,$1);scope.push(l);}
                        ;

%%

int main(int argc, char** argv)
{
    
    yyin = fopen(argv[1], "r");
    
    string temp = argv[1];
    string temp2 = argv[2];

    output_file_name = temp2;

    tac.open(output_file_name);

    yyparse();
}

int yyerror(char *s){
    printf("Error: %s\n", s);
}

