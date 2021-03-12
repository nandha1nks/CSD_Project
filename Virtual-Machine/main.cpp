#include<bits/stdc++.h>
#include "vm.h"

using namespace std;

int main(int argc, char** argv) {
    if(argc!=3 && argc !=2) {
        cout << "Error..." << endl;
        exit(1);
    }
    string inputFileName,outputFileName;
    if(argc==3) {
        inputFileName = argv[1];
        outputFileName = argv[2];
    }
    else {
        inputFileName = argv[1];
        outputFileName = "arm.s";
    }
    //cout << inputFileName << endl;
    //cout << outputFileName << endl;
    VM V(inputFileName, outputFileName);
    V.convertToAssembly(); // VM Translator Functionality
    return 0;
}