#ifndef WMCPU_INSPECTION_H
#define WMCPU_INSPECTION_H

#include "../util/Packet.h"
#include "inspection.h"
//#include "hash.h"
//#include "wminspection.h"//<--- incluir wminspection.h
#include <vector>
#include <iostream>
#include <string>
#include <queue>
#include <fstream>
#include <algorithm>
#include <math.h>
#include <stdio.h>

using namespace std;

class WMCPUInspection : public Inspection
{
    private:
	bool nextInput =true;
    int maxs_;
	std::vector<std::string> strFile;
	std::vector<std::string> padroes;
	int m;
	int nP;
	int M;
	int c=94; //[Null] ... a,b,c ... z, {. |. }
	//int c=4;
	double B;
	int B2;
	std::vector<std::vector<std::string>> vecpermu;
	std::vector<std::vector<std::string>> tabelaidx;
	std::vector<int> tbShift;	
	std::vector<std::vector<std::string>> tabelaHASH_;
	std::vector<std::vector<std::string>> tabelaPREFIX_;

	int N_;
	int pos_;
	int pref_;	
	std::vector<int> listaPadroes_;	
	std::string subData_;
	std::vector<std::string> listPotenPadr_;

    public:
        WMCPUInspection();
        WMCPUInspection(const Inspection &) = delete;
        WMCPUInspection& operator = (const Inspection &) = delete;
        ~WMCPUInspection();

        virtual void exec(std::shared_ptr<Packet> pkt);

        int buildMatchingMachine(std::string rules);
		int buildMatchingMachineTeste(std::string rules);
		int buildMatchingMachine1_1(std::string rules);
		int TmhMenorPadrao();
		int TmhTodosPadroes();
		double BlcStr();

    	void tabelaIdxHash();
		void vecPermu(); 
		void vecPermu1_1(); 
		void TabelaHash();
		void readfilesPadroes(std::string input);
		void readfilesData(std::string pkt);
		void tabelaShift();
		
		int Hash(std::string strBloco, int c, int M);
		std::vector<int> AdcTodosPadroesTabela(std::string str);
		
		void MatchPadroes(std::vector<std::string> listPotenPadr, std::string subData);
		void MatchPadroes1_1(int hash, std::string subData);
		void excWuManberCore(std::string nextData);
		void excWuManberCore1_1(std::string nextData);

		void PrecarregaTabelaHash(std::string subStr, int idxPadrao);
		void PrecarregaTabelaPrefix(std::string subStr);
};

#endif

