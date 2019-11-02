#ifndef WMGPU_INSPECTION_H
#define WMGPU_INSPECTION_H

#include "../util/Packet.h"
#include "inspection.h"
#include <vector>
#include <iostream>
#include <string>
#include <cstring>
#include <queue>
#include <fstream>
#include <algorithm>
#include <math.h>
#include <stdio.h>
#include <cuda_runtime.h>
#include "../util/helper_cuda.h"

#define MAXC_ 127

//#define N (2048*204*)
//#define THREADS_PER_BLOCK 512

using namespace std;

class WMGPUInspection : public Inspection
{
    private:
/* 
	int N = 33; //(2048 * 2048) //@@@ tamanho do vetor
	//int M = THREADS_PER_BLOCK = 8;//512 //  
	int M_ = 8; */

	// bool nextInput =true;
	int indexDebug;
	bool nextInput =true;
    int maxs_;
	// std::vector<std::string> strFile;
	// std::vector<std::string> padroes;
	int m;
	int nP;
	int M;
	//int c=94; //[Null] ... a,b,c ... z, {. |. }
	//int c=4;
	int c=128;
	int B;
	int B2;
	std::vector<std::vector<std::string>> vecpermu;
	std::vector<std::vector<std::string>> tabelaidx;
	std::vector<int> tbShift;	
	std::vector<std::vector<std::string>> tabelaHASH_;

	int tbHDataSize = 0;
	int countSizePadHash = 0;
	int conttbHData = 0;

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

	// std::vector<std::vector<std::string>> tabelaPREFIX_; 

	std::vector<std::string> padroes;

    public:
        WMGPUInspection();
		WMGPUInspection(const Inspection &) = delete;
		WMGPUInspection& operator = (const Inspection &) = delete;
        ~WMGPUInspection();

        virtual void exec(std::shared_ptr<Packet> pkt);

        int buildMatchingMachine(std::string rules, int bufferSize, int nThreads);
		int buildMatchingMachine1_1(std::string rules, int bufferSize, int nThreads);
		int TmhMenorPadrao();
		int TmhTodosPadroes();
		int BlcStr();

		void tabelaIdxHash();
		void vecPermu();
		void vecPermu1_1(); 
		void TabelaHash();
		// void readfilesPadroes(std::string input);
		// void readfilesData(std::string pkt);
		void tabelaShift();
		int Hash(std::string strBloco, int c, int M);
		std::vector<int> AdcTodosPadroesTabela(std::string str);

		void MatchPadroes(std::vector<std::string> listPotenPadr, std::string subData);
		void excWuManberCore(std::string nextData);
		void PrecarregaTabelaHash(std::string strTemp, int hash,char* dataTemp);
		bool hashEsgotado(int hash);

		void cuda_sample_random_ints(int* x,int N);
		void cuda_sample_print_ints(int* x,int N);
};

#endif
