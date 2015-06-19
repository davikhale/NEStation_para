// OS-specific networking includes
// -------------------------------

#include <string.h>
#include <iostream>
#include <fstream>
using namespace std;

#define DLL_EXPORT __declspec(dllexport)


extern "C" DLL_EXPORT const char* writevoice(int n, char *v[])
{
	ofstream voicefile;
	voicefile.open("scripts/voicequeue.txt", ios::out | ios::app);
	// extract args
    // ------------
    if(n < 1) return 0;
    string voicestring = v[0];
	voicefile << voicestring;
	voicefile.close();

    return "1";
}
