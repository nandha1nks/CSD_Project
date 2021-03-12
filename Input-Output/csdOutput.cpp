#include<iostream>
#include<fstream>
#include<string>
#include<streambuf>

using namespace std;

int main() {
	ifstream f;
	string s = "";
	int i=0;
	f.open("out.txt", ios::in);
	while(1) {
		string temp;
		f.seekg(0, ios::end);
		temp.reserve(f.tellg());
		f.seekg(0, ios::beg);
		
		temp.assign(istreambuf_iterator<char>(f), istreambuf_iterator<char>());
		
		if(temp != s && temp !="") {
			s = temp;
			cout<<s<<endl;
		}
	}
	f.close();
}
