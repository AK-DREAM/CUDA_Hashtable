#include <cstdio>
#include <iostream>
#include <algorithm>
#include <cuda_runtime.h>
#include "data_loader.h"
#include "mytools.h"
#include "dinner123.h"
using namespace std;
typedef unsigned long long ull;

int n = 100;
int pt[] = {0,10,20,50,100};

int main() {
    dinner123 Hashtable;
    cerr << "Initialized\n";
    for (int t = 0; t < 4; t++) {
        for (int i = pt[t]; i < pt[t+1]; i++) {
            cerr << "insert: " << i << endl;
            string name = "data/A/part_"+to_string(i);
            Hashtable.Insert((name+".keys").c_str(), (name+".vals").c_str());
            // cerr << "insert: " << i << " OK\n";
        }
        for (int i = pt[t]; i < pt[t+1]; i++) {
            cerr << "find: " << i << endl;
            string name = "data/A/part_"+to_string(i);
            Hashtable.Find((name+".keys").c_str());
            // cerr << "find: " << i << " OK\n";
        }
    }
    // Hashtable.Find("data/A/part_50.keys");

    for (int i = 0; i < 100; i++) {
        string name = "data/A/part_"+to_string(i);
        system(("diff "+name+".vals "+name+".myvals").c_str());
    }

    fprintf(stderr, "Insert Time: %f\nFind Time: %f\n", Hashtable.insTime, Hashtable.fndTime);
    return 0;
}