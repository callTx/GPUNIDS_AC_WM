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
	int indexDebug;
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

	int tbHDataSize = 0;
	int countSizePadHash = 0;
	int conttbHData = 0;

	int N_;
	int pos_;
	int pref_;	
	std::vector<int> listaPadroes_;	
	std::string subData_;
	std::vector<std::string> listPotenPadr_;

	char* tbHData;
	int* tbHPosData;
	int* tbHContPadHash;
	int* tbHSizePadHash;
	int* tbHIdxSizePadHash;

	char* d_tbHData = NULL;
	int* d_tbHPosData = NULL;
	int* d_tbHContPadHash= NULL;
	int* d_tbHSizePadHash= NULL;
	int* d_tbHIdxSizePadHash =NULL;

	int NUMBER_BLOCKS;
	int THREADS_PER_BLOCk;

	std::vector<int> arrHashEsgotados;

	std::vector<std::string> padroes;

	char* dataTemp;
	char* dataTemp2;

    public:
        WMCPUInspection();
        WMCPUInspection(const Inspection &) = delete;
        WMCPUInspection& operator = (const Inspection &) = delete;
        ~WMCPUInspection();


        virtual void exec(std::shared_ptr<Packet> pkt);

        int buildMatchingMachine(std::string rules);
		int buildMatchingMachineTeste(std::string rules);
		int buildMatchingMachine1_1(std::string rules);
		int buildMatchingMachine1_1_1(std::string rules);
		int TmhMenorPadrao();
		int TmhTodosPadroes();
		double BlcStr();

    	void tabelaIdxHash();
		void vecPermu(); 
		void vecPermu1_1();
		void vecPermu1_1_1(); 
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
		void PrecarregaTabelaHash1_1_1(std::string strTemp, int hash,char* dataTemp);
		void PrecarregaTabelaPrefix(std::string subStr);
};

#endif

