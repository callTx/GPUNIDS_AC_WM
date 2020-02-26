/**
 * Copyright 1993-2015 NVIDIA Corporation.  All rights reserved.
 *
 * Please refer to the NVIDIA end user license agreement (EULA) associated
 * with this source code for terms and conditions that govern your use of
 * this software. Any use, reproduction, disclosure, or distribution of
 * this software and related documentation outside the terms of the EULA
 * is strictly prohibited.
 *
 */

/**
 * Vector addition: C = A + B.
 *
 * This sample is a very basic sample that implements element by element
 * vector addition. It is the same as the sample illustrating Chapter 2
 * of the programming guide with some additions like error checking.
 */

#include <stdio.h>

// For the CUDA runtime routines (prefixed with "cuda_")
#include <cuda_runtime.h>

#include <helper_cuda.h>
/**
 * CUDA Kernel Device code
 *
 * Computes the vector addition of A and B into C. The 3 vectors have the same
 * number of elements numElements.
 */

#include <vector>
#include <iostream>
#include <string>
#include <cstring>
#include <queue>
#include <fstream>
#include <algorithm>
#include <math.h>
#include <stdio.h>

int TmhTodosPadroes();
int TmhMenorPadrao();
double BlcStr();
void vecPermu1_1();
void PrecarregaTabelaHash(std::string strTemp, int hash, char* dataTemp);

bool hashEsgotado(int hash);

int tbHDataSize = 0;
std::vector<std::string> padroes;
std::vector<int> arrHashEsgotados;
int* tbHContPadHash;
int* tbHPosData;
int* tbHSizePadHash;
int* tbHIdxSizePadHash;
int countSizePadHash = 0;


int B;
int M;
int c = 6;// 128
int m;
int nP;

char* tbHData;
int conttbHData = 0;
int indexDebug;
int THREADS_PER_BLOCk;
int NUMBER_BLOCKS;

char* d_tbHData = NULL;
int* d_tbHPosData = NULL;
int* d_tbHContPadHash = NULL;
int* d_tbHSizePadHash = NULL;
int* d_tbHIdxSizePadHash = NULL;

using namespace std;
/*
__global__ void vectorAdd(const float *A, const float *B, float *C, int numElements)
{
    int i = blockDim.x * blockIdx.x + threadIdx.x;

    if (i < numElements)
    {
        C[i] = A[i] + B[i];
    }
}
*/
/**
 * Host main routine
 */

/*
int
main(void)
{
    // Error code to check return values for CUDA calls
    cudaError_t err = cudaSuccess;

    // Print the vector length to be used, and compute its size
    int numElements = 50000;
    size_t size = numElements * sizeof(float);
    printf("[Vector addition of %d elements]\n", numElements);

    // Allocate the host input vector A
    float *h_A = (float *)malloc(size);

    // Allocate the host input vector B
    float *h_B = (float *)malloc(size);

    // Allocate the host output vector C
    float *h_C = (float *)malloc(size);

    // Verify that allocations succeeded
    if (h_A == NULL || h_B == NULL || h_C == NULL)
    {
        fprintf(stderr, "Failed to allocate host vectors!\n");
        exit(EXIT_FAILURE);
    }

    // Initialize the host input vectors
    for (int i = 0; i < numElements; ++i)
    {
        h_A[i] = rand()/(float)RAND_MAX;
        h_B[i] = rand()/(float)RAND_MAX;
    }

    // Allocate the device input vector A
    float *d_A = NULL;
    err = cudaMalloc((void **)&d_A, size);

    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to allocate device vector A (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }

    // Allocate the device input vector B
    float *d_B = NULL;
    err = cudaMalloc((void **)&d_B, size);

    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to allocate device vector B (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }

    // Allocate the device output vector C
    float *d_C = NULL;
    err = cudaMalloc((void **)&d_C, size);

    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to allocate device vector C (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }

    // Copy the host input vectors A and B in host memory to the device input vectors in
    // device memory
    printf("Copy input data from the host memory to the CUDA device\n");
    err = cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);

    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to copy vector A from host to device (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }

    err = cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);

    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to copy vector B from host to device (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }

    // Launch the Vector Add CUDA Kernel
    int threadsPerBlock = 256;
    int blocksPerGrid =(numElements + threadsPerBlock - 1) / threadsPerBlock;
    printf("CUDA kernel launch with %d blocks of %d threads\n", blocksPerGrid, threadsPerBlock);
    vectorAdd<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C, numElements);
    err = cudaGetLastError();

    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to launch vectorAdd kernel (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }

    // Copy the device result vector in device memory to the host result vector
    // in host memory.
    printf("Copy output data from the CUDA device to the host memory\n");
    err = cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);

    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to copy vector C from device to host (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }

    // Verify that the result vector is correct
    for (int i = 0; i < numElements; ++i)
    {
        if (fabs(h_A[i] + h_B[i] - h_C[i]) > 1e-5)
        {
            fprintf(stderr, "Result verification failed at element %d!\n", i);
            exit(EXIT_FAILURE);
        }
    }

    printf("Test PASSED\n");

    // Free device global memory
    err = cudaFree(d_A);

    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to free device vector A (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }

    err = cudaFree(d_B);

    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to free device vector B (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }

    err = cudaFree(d_C);

    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to free device vector C (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }

    // Free host memory
    free(h_A);
    free(h_B);
    free(h_C);

    printf("Done\n");
    return 0;
}
*/

__global__ void
wmkernel(char* dataTemp, int* tbHContPadHash, int* tbHPosData, int* tbHSizePadHash, int* tbHIdxSizePadHash, char* tbHData, int N, double B, int c, int M, int* posicao) {

	int index = blockDim.x * blockIdx.x + threadIdx.x;




	if (index < N - B + 1) {
		//posicao[index] = index;

		int hash = 0;
		for (int i = index; i < index + B; i++) {
			hash = hash + dataTemp[i] * (c ^ (i - index));
			hash = hash % M;
		}
		//posicao[index] = hash;

		int tamArrPadrao = 0;
		for (unsigned t = 0; t < tbHContPadHash[hash]; t++) {
			int match = 1;

			int posIniPadrao = tbHPosData[hash] - 1;
			tamArrPadrao = tamArrPadrao + tbHSizePadHash[tbHIdxSizePadHash[hash] + t];
			int tamPadrao = tbHSizePadHash[tbHIdxSizePadHash[hash] + t];
			int _final = (index + B) - 1;
			int _final2 = tamPadrao;
			for (int ch = tamArrPadrao; ch >= 0; --ch) {
				if (_final2 - 1 >= 0) {

					if (tbHData[posIniPadrao + ch - 1] == dataTemp[_final]) {
						_final = _final - 1;
						_final2 = _final2 - 1;

					}
					else {
						match = 0;
						break;
					}
				}
				else {

					break;
				}
			}
			if (match) {
				posicao[index] = _final + 1;


			}
		}


	}


}

void execGPU() {
	
	std::cout << std::endl;
	std::cout << "Inicio exec" << std::endl;

	cudaError_t err = cudaSuccess;

	//========== aloca host, aloca device dataTemp ==========
	char* dataTemp;
	dataTemp = "Accept|3A|gk3Connectionkkjwf/;.bCer.93senduuname";

	int N = strlen(dataTemp);
	size_t sizeChar = N * sizeof(char);

	char* d_dataTemp = NULL;
	err = cudaMalloc((void**)& d_dataTemp, sizeChar);
	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to allocate device vector d_dataTemp (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}
	//==========fim aloca host, aloca device dataTemp ==========

	//============ copia device dataTemp ===============================
	err = cudaMemcpy(d_dataTemp, dataTemp, sizeChar, cudaMemcpyHostToDevice);

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to copy vector dataTemp from host to device (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}
	//============fim copia device dataTemp ===============================

	//=========== aloca host,aloca device posicao===============
	size_t size = N * sizeof(int);
	int* posicao;
	int* d_posicao = NULL;

	posicao = (int*)calloc(N, size);
	cudaMalloc((void**)& d_posicao, size);
	//===========fim: aloca host,aloca device posicao===============

	//======== verifica se N e multiplo de THREADS_PER_BLOCk ======================
	NUMBER_BLOCKS = N / THREADS_PER_BLOCk;
	cout << "\n";
	cout << "NUMBER_BLOCKS: " << NUMBER_BLOCKS << "\n";

	int X_;
	int Y_;
	if (N % THREADS_PER_BLOCk == 0) {
		cout << "N/ THREADS_PER_BLOCk: " << N / THREADS_PER_BLOCk << " e multiplo";
		X_ = N / THREADS_PER_BLOCk;
		Y_ = THREADS_PER_BLOCk;
	}
	else {
		cout << "N/ THREADS_PER_BLOCk: " << N / THREADS_PER_BLOCk << " noa e multiplo";
		X_ = (NUMBER_BLOCKS + THREADS_PER_BLOCk - 1) / THREADS_PER_BLOCk;
		Y_ = THREADS_PER_BLOCk;
	}
	//========fim verifica se N e multiplo de THREADS_PER_BLOCk ======================


	//=======executa o kernel=====================================================
	wmkernel<<< X_, Y_ >>>(d_dataTemp, d_tbHContPadHash, d_tbHPosData, d_tbHSizePadHash, d_tbHIdxSizePadHash, d_tbHData, N, B, c, M, d_posicao);

	err = cudaGetLastError();

	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to launch wmkernel kernel (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}
	//=======fim executa o kernel=====================================================

	cout << "\n";

	//=======copia saidas do device p/ host=====================================================
	err = cudaMemcpy(posicao, d_posicao, size, cudaMemcpyDeviceToHost);
	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to copy vector posicao from device to host (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	/*
	err = cudaMemcpy(teste, d_teste, sizeChar, cudaMemcpyDeviceToHost);
	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to copy vector d_teste from device to host (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}
	*/



	for (int i = 0; i < N; i++) {
		//if(posicao[i]>0) 
		printf("posicao[%d]  %d ha um match \n", i, posicao[i]);

	}
	//=======fim copia saidas do device p/ host=====================================================

	cudaFree(d_dataTemp);
	cudaFree(d_tbHContPadHash);
	cudaFree(d_tbHPosData);
	cudaFree(d_tbHSizePadHash);
	cudaFree(d_tbHIdxSizePadHash);
	cudaFree(d_tbHData);
	cudaFree(d_posicao);

	std::cout << std::endl;
	std::cout << "Fim exec" << std::endl;

}


void execCPU() {

	std::string dataTemp = "ABEDEDAGB";

	//int N = conttbHData;
	int N = dataTemp.size();

	int pos = 0;

	while (pos <= N - B) {
		//posicao[index] = index;

		int hash = 0;
		for (int i = pos; i < pos+B; i++) {
			hash = hash + dataTemp[i] * (c ^ (i - pos));
			hash = hash % M;
		}
		//posicao[index] = hash;

		int tamArrPadrao = 0;
		for (unsigned t = 0; t < tbHContPadHash[hash]; t++) {
			int match = 1;

			int posIniPadrao = tbHPosData[hash] - 1;
			tamArrPadrao = tamArrPadrao + tbHSizePadHash[tbHIdxSizePadHash[hash] + t];
			int tamPadrao = tbHSizePadHash[tbHIdxSizePadHash[hash] + t];
			int _final = (pos + B) - 1;
			int _final2 = tamPadrao;
			for (int ch = tamArrPadrao; ch >= 0; --ch) {
				if (_final2 - 1 >= 0) {

					if (tbHData[posIniPadrao + ch - 1] == dataTemp[_final]) {
						_final = _final - 1;
						_final2 = _final2 - 1;

					}
					else {
						match = 0;
						break;
					}
				}
				else {

					break;
				}
			}
			if (match) {
				//posicao[index] = _final + 1;
				cout << "Ha um match a partir da posicao " << _final + 1 << " do  pacote capturado" << endl;


			}
		}

		pos = pos + 1;
	}
}

int
main(void)
{
	THREADS_PER_BLOCk = 32;

	std::string dir = "C:/Users/danie/Documents/Projects/TCC/GPUNIDS_AC_WM/rulesDebug.txt";
	std::string dir2 = "C:/Users/danie/Documents/Projects/TCC/Wu-Wanber/teste/padroes/padroes.txt";

	std::ifstream file(dir);
	std::string str;
	while (std::getline(file, str)) {
		//std::cout << str << "n";
		padroes.push_back(str);
	}


	m = TmhMenorPadrao();
	nP = padroes.size();
	//cout << "nP: " << nP << "\n";
	M = TmhTodosPadroes();
	B = BlcStr();

	for (int i = 0; i < nP; i++) {

		tbHDataSize = tbHDataSize + padroes.at(i).size() * (padroes.at(i).size() - (B - 1));

	}

	arrHashEsgotados = std::vector<int> (tbHDataSize);

	size_t sizeChar = tbHDataSize * sizeof(char);
	size_t sizeInt = M * sizeof(int);
	//tbHData = (char*)calloc(tbHDataSize, sizeChar);


	//================aloca host tbHPosData/tbHContPadHash/tbHSizePadHash/tbHIdxSizePadHash/tbHData
	tbHPosData = (int*)malloc(sizeInt);
	//tbHContPadHash = (int*) malloc(sizeInt);
	tbHContPadHash = (int*)calloc(M, sizeInt);
	tbHSizePadHash = (int*)malloc(sizeInt);
	tbHIdxSizePadHash = (int*)malloc(sizeInt);
	//tbHData = (char*) malloc(sizeChar);
	tbHData = (char*)calloc(tbHDataSize, sizeof(char)); //tbHData = (char*)calloc(tbHDataSize, sizeChar);
	//================fim aloca host tbHPosData/tbHContPadHash/tbHSizePadHash/tbHIdxSizePadHash/tbHData

	
	vecPermu1_1();

	execCPU();


	size_t sizeChartb = tbHDataSize * sizeof(char);
	size_t sizeInttb = M * sizeof(int);

	cudaError_t err = cudaSuccess;
	//=========== aloca device d_tbHData/d_tbHContPadHash/d_tbHPosData/d_tbHSizePadHash/d_tbHIdxSizePadHash
	err = cudaMalloc((void**)& d_tbHData, sizeChartb);
	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to allocate device vector d_tbHData (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	err = cudaMalloc((void**)& d_tbHContPadHash, sizeInttb);
	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to allocate device vector d_tbHContPadHash (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	err = cudaMalloc((void**)& d_tbHPosData, sizeInttb);
	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to allocate device vector d_tbHPosData (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	err = cudaMalloc((void**)& d_tbHSizePadHash, sizeInttb);
	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to allocate device vector d_tbHSizePadHash (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	err = cudaMalloc((void**)& d_tbHIdxSizePadHash, sizeInttb);
	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to allocate device vector d_tbHIdxSizePadHash (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}
	//===========fim aloca device d_tbHData/d_tbHContPadHash/d_tbHPosData/d_tbHSizePadHash/d_tbHIdxSizePadHash

	//========== copia host->device tbHPosData/tbHContPadHash/tbHSizePadHash/tbHIdxSizePadHash/tbHData====
	err = cudaMemcpy(d_tbHData, tbHData, sizeChartb, cudaMemcpyHostToDevice);
	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to copy vector tbHData from host to device (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	err = cudaMemcpy(d_tbHContPadHash, tbHContPadHash, sizeInttb, cudaMemcpyHostToDevice);
	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to copy vector tbHContPadHash from host to device (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	err = cudaMemcpy(d_tbHPosData, tbHPosData, sizeInttb, cudaMemcpyHostToDevice);
	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to copy vector tbHPosData from host to device (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	err = cudaMemcpy(d_tbHSizePadHash, tbHSizePadHash, sizeInttb, cudaMemcpyHostToDevice);
	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to copy vector tbHSizePadHash from host to device (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	err = cudaMemcpy(d_tbHIdxSizePadHash, tbHIdxSizePadHash, sizeInttb, cudaMemcpyHostToDevice);
	if (err != cudaSuccess)
	{
		fprintf(stderr, "Failed to copy vector tbHIdxSizePadHash from host to device (error code %s)!\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}
	//==========fim copia host->device tbHPosData/tbHContPadHash/tbHSizePadHash/tbHIdxSizePadHash/tbHData====
	
	

	return 0;

}

int TmhMenorPadrao() {

	std::vector<int> sizePadroes;
	for (int i = 0; i < padroes.size(); ++i) {
		sizePadroes.push_back(padroes[i].size());
	}
	auto minElem = std::min_element(std::begin(sizePadroes), std::end(sizePadroes));
	//std::cout<<minElem.operator*()+"\n"<<std::endl;


	return minElem.operator*();
}

int TmhTodosPadroes() {

	int TodosP = m * nP;

	return  TodosP;
}

double BlcStr() {

	double blcStr = log10(2 * M) / log10(c);
	//double B = std::ceil(blcStr);
	double Blc = std::round(blcStr);
	return Blc;
}


void vecPermu1_1() {

	
	char* dataTemp = NULL;
	//int sizeCharDT = B * sizeof(char);
	size_t sizeChar = B * sizeof(char);//size_t sizeChar = tbHDataSize * sizeof(char);
	//dataTemp = (char*) malloc(sizeCharDT);
	//dataTemp = (char*) calloc(B,sizeCharDT);
	dataTemp = (char*)calloc(B, sizeChar);//dataTemp = (char*)calloc(tbHDataSize, sizeChar);
	//vecpermu = std::vector<std::vector<std::string>>(nP,std::vector<std::string>());


	//tabelaHASH_ = std::vector<std::vector<std::string>> (M,std::vector<std::string>()); //2*nP

	for (int i = 0; i < padroes.size(); ++i) {
		std::string strTemp = padroes[i];
		std::string subStrPerm;

		int idxInicio = 0;
		int idxFim = B - 1;

		//cout<<"idxInicio: "<<idxInicio<<"\n";
		//cout<<"idxFim: "<<idxFim<<"\n";

		//std::cout << "padrao: " << strTemp << std::endl;

		while (idxFim < strTemp.length()) {

			subStrPerm = strTemp.substr(idxInicio, B);
			//cout<<"subStrPerm: "<<subStrPerm<<std::endl;
			int contDataTemp = 0;
			for (int p = 0; p < subStrPerm.size(); ++p) {
				//if(subStrPerm[p] != '\0'){
				dataTemp[p] = subStrPerm[p];
				contDataTemp++;
				//cout << dataTemp[p];
				//}
			}
			//std::cout << "erro" << std::endl;

			int hash = 0;
			
			for (int i = 0; i < contDataTemp; i++) {//for (int i = 0; i < strlen(dataTemp); i++) {
				hash = hash + dataTemp[i] * (c ^ (i));
				hash = hash % M;
			}

			//cout<<"hash: "<<hash<<std::endl;

			if (!(hashEsgotado(hash))) {
				PrecarregaTabelaHash(strTemp, hash, dataTemp);
			}



			//PrecarregaTabelaHash(strTemp, hash,dataTemp);
			//PrecarregaTabelaHash(subStrPerm,i);

			if (idxInicio == idxFim) {
				idxFim = idxFim + 1;
				idxInicio = idxFim;
			}
			else {
				idxInicio = idxInicio + 1;
				idxFim = idxFim + 1;
			}

		}

	}
	//std::cout <<"	padroes.size: "<<padroes.size()<<std::endl;
	//std::cout <<"	tabelaHASH_.size: "<<tabelaHASH_.size()<<std::endl;

	//cout << "fim vecPermu1_1" << endl;

	delete[] dataTemp;
	//free(dataTemp);

	std::cout << std::endl;
	std::cout << "Fim inicializacao de tabelas" << std::endl;
}


bool hashEsgotado(int hash) {


	if (std::find(std::begin(arrHashEsgotados), std::end(arrHashEsgotados), hash) != std::end(arrHashEsgotados)) {
		return true;
	}
	else {
		return false;
	}

}


void PrecarregaTabelaHash(std::string strTemp, int hash, char* dataTemp) {

	
	char* dataTemp2 = NULL;//char* dataTemp2;
	//int sizeCharDT2 = B * sizeof(char);
	size_t sizeChar = B * sizeof(char);//size_t sizeChar = tbHDataSize * sizeof(char);
	//dataTemp2 = (char*) malloc(sizeCharDT2);
	//dataTemp2 = (char*) calloc(B,sizeCharDT2);
	dataTemp2 = (char*)calloc(B, sizeChar);


	for (int j = 0; j < padroes.size(); j++) {
		bool hashEsgotadoPadraoAtual = false;
		std::string strTemp2 = padroes[j];



		int idxInicio2 = 0;
		int idxFim2 = B - 1;


		while (idxFim2 < strTemp2.length()) {
			std::string subStrPerm2 = strTemp2.substr(idxInicio2, B);


			int contdataTemp2 = 0;
			for (int p = 0; p < subStrPerm2.size(); ++p) {
				dataTemp2[p] = subStrPerm2[p];
				//cout<<dataTemp2[p];
				contdataTemp2++;
			}



			int hash2 = 0;
			for (int i = 0; i < contdataTemp2; i++) {//for (int i = 0; i < strlen(dataTemp); i++) {
				hash2 = hash2 + dataTemp2[i] * (c ^ (i));
				hash2 = hash2 % M;
			}


			/*
			if (indexDebug == 163009) {
				cout << endl;
				cout << "indexDebug: 163009" << endl;
				cout << "hash:"<<hash <<" - hash2: "<< hash2 << endl;
				cout << "strTemp:" << strTemp << " - strTemp2: " << strTemp2 << endl;
			}*/

			if (hash == hash2) {//if(hash == hash2 && !(hashEsgotado(hash))  ) {
				//cout << "hash==hash2" << endl;
				if (!hashEsgotadoPadraoAtual) {

					/*
					if (indexDebug == 163009) {
						cout << "indexDebug: 163009" << endl;
						cout << "hash nao esgotado" << endl;
					}*/
					
					if (!strTemp.compare(strTemp2)) {

						/*
						if (indexDebug == 163009) {
							cout << "indexDebug: 163009" << endl;
							cout << "strTemp==strTemp2" << endl;
						}*/
						

						int posIn = 0;
						int min = conttbHData; //int min = strlen(tbHData);

						//cout << " strlen(tbHData): " << min << endl;

						posIn = min;
						int max = strTemp.size() + conttbHData;//int max = strTemp.size() + strlen(tbHData);
						int idx = 0;
						//cout << "\n";



						//cout<<"min: "<<min<<"\n";
						//cout<<"max: "<<max<<"\n";
						for (int d = min; d < max; d++) {
							//if( strTemp[idx] != '\0'){
							tbHData[d] = strTemp[idx];
							idx = idx + 1;
							cout << "[" << d << "]: " << tbHData[d] << '\n';
							indexDebug = d;
							
							conttbHData = conttbHData + 1;
							//}
						}
						//cout<<">>>>>hash"<<hash<<"\n";
						//cout<<">>>>>crash1"<<"\n";

						if (tbHContPadHash[hash] == 0) {//if (tbHPosData[hash] <= 0) { //exe:  -3453456 (lixo de memoria)
							tbHPosData[hash] = posIn + 1;
							cout << "tbHPosData[" << hash << "]: " << tbHPosData[hash] << "  ";
						}

						int cont = tbHContPadHash[hash];
						tbHContPadHash[hash] = cont + 1;
						cout << "tbHContPadHash[" << hash << "]: " << tbHContPadHash[hash] << "  ";

						tbHSizePadHash[countSizePadHash] = strTemp.size();
						cout << "tbHSizePadHash[" << countSizePadHash << "]: " << tbHSizePadHash[countSizePadHash]							<< "  ";


						tbHIdxSizePadHash[hash] = countSizePadHash;
						cout << "tbHIdxSizePadHash[" << hash << "]: " << tbHIdxSizePadHash[hash] << "\n";

						hashEsgotadoPadraoAtual = true;
						countSizePadHash++;
					}else {

						/*
						if (indexDebug == 163009) {
							cout << "indexDebug: 163009" << endl;
							cout << "strTemp!=strTemp2" << endl;
						}*/
						

						int posIn = 0;
						int min = conttbHData; //int min = strlen(tbHData);

						posIn = min;
						int max = strTemp2.size() + conttbHData; //int max = strTemp2.size() + strlen(tbHData);
						int idx = 0;
						//cout << "\n";

						//cout<<"min: "<<min<<"\n";
						//cout<<"max: "<<max<<"\n";
						for (int d = min; d < max; d++) {
							//if(strTemp2[idx] != '\0'){
							tbHData[d] = strTemp2[idx];
							idx = idx + 1;
							cout << "[" << d << "]: " << tbHData[d] << '\n';
							conttbHData = conttbHData + 1;
							indexDebug = d;
							//}
						}
						//cout<<">>>>>hash"<<hash<<"\n";
						//cout<<">>>>>crash2"<<"\n";

						if (tbHContPadHash[hash] == 0) {//if (tbHPosData[hash] <= 0) { //exe:  -3453456 (lixo de memoria)
							tbHPosData[hash] = posIn + 1;
							cout << "tbHPosData[" << hash << "]: " << tbHPosData[hash] << "  ";
						}


						int cont = tbHContPadHash[hash];
						tbHContPadHash[hash] = cont + 1;
						cout << "tbHContPadHash[" << hash << "]: " << tbHContPadHash[hash] << "  ";


						tbHSizePadHash[countSizePadHash] = strTemp2.size();
						cout << "tbHSizePadHash[" << countSizePadHash << "]: " << tbHSizePadHash[countSizePadHash]							<< "  ";


						//if(tbHIdxSizePadHash[hash] < 0) {
						//    tbHIdxSizePadHash[hash] = countSizePadHash;
						//    cout << "tbHIdxSizePadHash[" << hash << "]: " << tbHIdxSizePadHash[hash] << "\n";
						//}

						hashEsgotadoPadraoAtual = true;
						countSizePadHash++;
					}
				}
				//cout << "hash esgotado" << endl;
			}
			//cout << "hash!=hash2" << endl;


			if (idxInicio2 == idxFim2) {
				idxFim2 = idxFim2 + 1;
				idxInicio2 = idxFim2;
			}
			else {
				idxInicio2 = idxInicio2 + 1;
				idxFim2 = idxFim2 + 1;
			}

		}


		if (j == padroes.size() - 1) {
			arrHashEsgotados.push_back(hash);
		}


	}

	//cout << "fim vecPermu1_1" << endl;
	delete[] dataTemp2;
	//free(dataTemp2);
}


