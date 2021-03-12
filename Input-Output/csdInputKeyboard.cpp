#include<iostream>
#include<string.h>
#include<fstream>

using namespace std;
string hex(int t) {
	string ex = "0";
	if(t<0) {
		t += 65536;
		ex = "F";
	}
	string s = "";
	while(t>0) {
		char c;
		if(t%16 < 10) {
			c = t%16 + 48;
		} else {
			c = 'A' + t%16 -10;
		}
		t/=16;
		s = c+s;
	}
	while(s.length() < 8) {
		s = ex + s;
	} 
	return s;
}

int main() {
	int c;
	ofstream file;
	file.open("input.txt", ios::out | ios::trunc);
	file<<"00000000"<<endl;
	file.close();
	while(1) {
		cin>>c;
		int a = c;
		file.open("input.txt", ios::out | ios::trunc);
		string s = hex(a);
		cout<<"hex val "<<hex(a)<<endl;
		file<<s<<endl;
		file.close();
	}
	return 0;
}
