#include"WMGPUinspection.h"


WMGPUInspection::WMGPUInspection()
{

}

WMGPUInspection::~WMGPUInspection()
{
	free(tbHData);
}

void WMGPUInspection::cuda_sample_random_ints(int* x,int N){

	for(int i=0; i<N;i++){
		x[i]=rand();
	}
}

void WMGPUInspection::cuda_sample_print_ints(int* x,int N){

	for(int i=0; i<N;i++){
		std::cout<<"x["<<i<<"]: "<<x[i]<<std::endl;
	}
}

/*
 __global__ void add(int *x,int *y,int *z){
	*z= *x+ *y; //Heterogeneous computing
	//c[blockIdx.x] = a[blockIdx.x] + b[blockIdx.x]; //Blocks
	//c[threadIdx.x] = a[threadIdx.x] + b[threadIdx.x]; //Threads
	
	//int index = threadIdx.x + blockIdx.x * blockDim.x; //
	//if(index < n) c[index] = a[index] + b[index];
	
		//c [ 0 ] = a[0] + b[0]  ----- c[1] = a[1] +b[1]
	
} */



__global__ void
wmkernel(char *dataTemp,int *tbHContPadHash,int *tbHPosData,int *tbHSizePadHash,int *tbHIdxSizePadHash,char *tbHData,int N,double B,int c, int M, int *posicao){	

	int index = blockDim.x * blockIdx.x + threadIdx.x;
	
		
	
	
	if(index < N-B+1){
		//posicao[index] = index;
		
		int hash=0;
		for(int i=index;i<index+B;i++){
			hash = hash + dataTemp[i]*(c^(i-index));
			hash = hash % M;
		}
		//posicao[index] = hash;

		int tamArrPadrao = 0;
		for(unsigned t =0; t< tbHContPadHash[hash]; t++){
			int match = 1;

			int posIniPadrao = tbHPosData[hash]-1;
			tamArrPadrao = tamArrPadrao+ tbHSizePadHash[ tbHIdxSizePadHash[hash] +t ];
			int tamPadrao = tbHSizePadHash[ tbHIdxSizePadHash[hash] +t ];
			int _final = (index + B) -1; 
			int _final2 = tamPadrao;
			for (int ch = tamArrPadrao; ch>=0; --ch){
				if(_final2 -1 >=0){

					if(tbHData[posIniPadrao+ch-1] == dataTemp[_final]){
						_final = _final - 1;
						_final2 = _final2 -1;

					}else{
						match = 0;
						break;
					}
				}else{
					
					break;
				}
			}
			if (match){
				posicao[index] = _final +1;
			

			}
		}
		

	}
	
	
}





void WMGPUInspection::exec(std::shared_ptr<Packet> pkt){
    
	#ifdef VERBOSE
			struct timeval start, end, diff;
			gettimeofday(&end, nullptr);
			timersub(&end, &(pkt.get()->virtualTime), &diff);
			this->lock();
			pkt->computeStatistics(this->getStats());
			this->getStats()->sumWaitingTime += diff.tv_sec * 1000.0 + diff.tv_usec / 1000.0;
			this->unlock();

			if( gettimeofday(&start, nullptr) != 0)
			{
				std::cerr << "Fail to get current time" << std::endl;
				exit(-1);
			}
	#endif

	pkt.get()->init();
	if(nextInput && pkt.get()->size_payload_ > 0){
			nextInput = false;
			
			cudaError_t err = cudaSuccess;

			//========== aloca host, aloca device dataTemp ==========
			char* dataTemp;
			dataTemp = reinterpret_cast<char*>(pkt.get()->payload_);;
			
			int N = strlen(dataTemp);
			size_t sizeChar = N * sizeof(char);

			char* d_dataTemp = NULL;
			err = cudaMalloc((void **)&d_dataTemp, sizeChar);
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
			int *posicao;
			int *d_posicao = NULL;

			posicao = (int *)calloc(N,size);
			cudaMalloc((void **)&d_posicao, size);
			//===========fim: aloca host,aloca device posicao===============


			//======aloca host,aloca device teste===========
			/*
			char *teste;
			char *d_teste = NULL;

			teste = (char *)calloc(N,sizeChar);
			cudaMalloc((void **)&d_teste, sizeChar);
			*/
			//======fim aloca host,aloca device teste===========



			//======== verifica se N e multiplo de THREADS_PER_BLOCk ======================
			NUMBER_BLOCKS = N/ THREADS_PER_BLOCk;
			cout<<"\n";
			cout<<"NUMBER_BLOCKS: "<<NUMBER_BLOCKS<<"\n";

			int X_;
			int Y_;
			if(N%THREADS_PER_BLOCk ==0){
				cout<<"N/ THREADS_PER_BLOCk: "<<N/ THREADS_PER_BLOCk<<" e multiplo";
				X_ = N/THREADS_PER_BLOCk;
				Y_ = THREADS_PER_BLOCk;
			}else{
				cout<<"N/ THREADS_PER_BLOCk: "<<N/ THREADS_PER_BLOCk<<" noa e multiplo";
				X_ =(NUMBER_BLOCKS + THREADS_PER_BLOCk -1)/THREADS_PER_BLOCk;
				Y_ = THREADS_PER_BLOCk;
			}
			//========fim verifica se N e multiplo de THREADS_PER_BLOCk ======================


			//=======executa o kernel=====================================================
			wmkernel<<< X_, Y_  >>>(d_dataTemp,d_tbHContPadHash,d_tbHPosData,d_tbHSizePadHash,d_tbHIdxSizePadHash,d_tbHData,N, B, c, M, d_posicao);	

			err = cudaGetLastError();

			if (err != cudaSuccess)
			{
				fprintf(stderr, "Failed to launch wmkernel kernel (error code %s)!\n", cudaGetErrorString(err));
				exit(EXIT_FAILURE);
			}
			//=======fim executa o kernel=====================================================

			cout<<"\n";


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

			

			for(int i=0;i<N;i++){
				//if(posicao[i]>0) 
				printf("posicao[%d]  %d ha um match \n",i,posicao[i]);
				
			}
			//=======fim copia saidas do device p/ host=====================================================

			cudaFree(d_dataTemp);
			cudaFree(d_tbHContPadHash);
			cudaFree(d_tbHPosData);
			cudaFree(d_tbHSizePadHash);
			cudaFree(d_tbHIdxSizePadHash);
			cudaFree(d_tbHData);
			cudaFree(d_posicao);
		



			#ifdef VERBOSE
				//:::::::::::::      
				//:::::::::::::      blocks number = N / THREADS_PER_BLOCK  

				//add<<<(N+M-1)/M, M >>>(d_a,d_b,d_c,N); //threads_per_block with vector which is not multiple of the blockDim.x = M
				//nextInput = false;
				//std::cout<<">>>>>>>>>>>>>>>>payload_[ ]: " <<reinterpret_cast<char*>( pkt.get()->payload_) <<std::endl;
				//std::cout<< "size: " << pkt.get()->size_payload_ <<std::endl;
				//this->excWuManberCore( reinterpret_cast<char*>(pkt.get()->payload_) );
				//cout<<"dataTemp: "<<dataTemp<<"\n";
				//int pos = m;
				//int pref = m - B2;
				//cout<< ">>>>>>>>>>>WuManberCore1_1: " <<endl;	
				//std::string dataTemp = nextData;
				//std::string dataTemp = "ABEDEDABG";
				//std::cout<<"dataTemp: "<<dataTemp <<std::endl;
				//int N = dataTemp.length();
				//cout <<">>>>>>>>>>>>>N: "<<N<< endl;
				//cout <<">>>>>>>>>>>>>pos: "<<pos<< endl;
				//cout <<">>>>>>>>>>>>>pref: "<<pref<< endl;
			#endif
		
	}

	#ifdef VERBOSE

			if( gettimeofday(&end, nullptr) != 0)
			{
				std::cerr << "Fail to get current time" << std::endl;
				exit(-1);
			}
			timersub(&end, &start, &diff);
			this->lock();
			this->getStats()->sumProcTime += diff.tv_sec * 1000.0 + diff.tv_usec / 1000.0;
			this->unlock();
	#endif
	
}


void WMGPUInspection::excWuManberCore(std::string  nextData){	
}

int WMGPUInspection::buildMatchingMachine(std::string rules, int bufferSize, int nThreads)
{
		//std::cout<<"nThreads: "<<nThreads<<std::endl;
		
		// (14-15/05) getilne -- TmhMenorPadrao() -- padroes.size() -- TmhTodosPadroes() -- BlcStr -- B2=B --  tabeleIdxHash() -- vecPermu() -- TabelaHash() 

		//TODO (20/05) buildMatchingMachine

		std::string line;
    	ifstream file(rules.c_str(), std::ifstream::in);
    	maxs_ = 0;
    	while(getline(file,line))
    	{
        	padroes.push_back(line);    
        	maxs_ += line.size();
		}
		
		m = TmhMenorPadrao();
		nP = padroes.size();
		M = TmhTodosPadroes();
		B = BlcStr(); 
		B2 = B;
		#ifdef VERBOSE
			cout<< "Inicializando tabelas........................... " <<endl;	
		#endif

		tabelaIdxHash();
		//tabelaShift();

		#ifdef VERBOSE
			cout<< "Tabelas inicializadas........................... " <<endl;	
		#endif

		return 1;

		/*
		int *a,*b,*c;
		//int a,b,c;
		int *d_a,*d_b,*d_c; 
		// size= sizeof(int);
		//std::cout<<"N: "<<N<<std::endl;
		int size = N * sizeof(int);

		//Aloca espaco para o device copiar de a,b,c
		cudaMalloc( (void **)&d_a,size );		
		cudaMalloc( (void **)&d_b,size );		
		cudaMalloc( (void **)&d_c,size );
		
		a = (int*)malloc(size);
		cuda_sample_random_ints(a,N);
		b= (int*)malloc(size);
		cuda_sample_random_ints(b,N);
		c= (int*)malloc(size);


		//a =2;
		//b =7;
		//copia a,b para o device
		cudaMemcpy(d_a,a,size,cudaMemcpyHostToDevice);		
		cudaMemcpy(d_b,b,size,cudaMemcpyHostToDevice);	

		//Launch o kernel add() na GPU
		//add<<<N,1>>>(d_a,d_b,d_c); //blocks
		//add<<<1,N>>>(d_a,d_b,d_c); //threads

		
		//:::::::::::::      N/THREADS_PER_BLOCK  = blocks number
		
		//add<<<N/THREADS_PER_BLOCK,THREADS_PER_BLOCK>>>(d_a,d_b,d_c); //threads_per_block with vector multiple of blockDim.x = M 

		add<<<(N+M-1)/M, M >>>(d_a,d_b,d_c,N); //threads_per_block with vector which is not multiple of the blockDim.x = M	

		//Copiar os resultados de volta p/ host
		cudaMemcpy(c,d_c,size,cudaMemcpyDeviceToHost);

		//cuda_sample_print_ints(c,N);
		//std::cout<<"c: "<<c<<std::endl;
		
		//Cleanup
		cudaFree(d_a);
		cudaFree(d_b);
		cudaFree(d_c);

		//char *cudaGetErrorString(cudaError_t);
		//printf("%s\n",cudaGetErrorString(cudaGetLastError()));

		return 0;
		*/
		
}

int WMGPUInspection::buildMatchingMachine1_1(std::string rules,int bufferSize, int nThreads){
	THREADS_PER_BLOCk = nThreads;
	
	std::string line;
	ifstream file(rules.c_str(), std::ifstream::in);
	maxs_ = 0;
	

	while(getline(file,line))
	{
		padroes.push_back(line);
		
		maxs_ += line.size();
	}

	

	m = TmhMenorPadrao();
	
	nP = padroes.size();

	cout<<"nP: "<<nP<<"\n";


	M = TmhTodosPadroes();

	B = BlcStr(); 


	B2 = B;

	tbHDataSize = 0;
	cout<<"B: "<<B<<"\n";
	
	for (int i =0;i< nP;i++) {
		
        tbHDataSize = tbHDataSize + padroes.at(i).size()*(padroes.at(i).size() - (B-1));
	}
	
	//cout<<"tbHDataSize: "<<tbHDataSize<<"\n";

	#ifdef VERBOSE
		cout<< "Inicializando tabelas........................... " <<endl;	
	#endif


	size_t sizeChar = tbHDataSize * sizeof(char);	
	size_t sizeInt = M * sizeof(int);
	
	
	//================aloca host tbHPosData/tbHContPadHash/tbHSizePadHash/tbHIdxSizePadHash/tbHData
    tbHPosData = (int*) malloc(sizeInt);
	//tbHContPadHash = (int*) malloc(sizeInt);
	tbHContPadHash = (int*) calloc(M,sizeInt);
    tbHSizePadHash = (int*) malloc(sizeInt);
    tbHIdxSizePadHash = (int*) malloc(sizeInt);
	//tbHData = (char*) malloc(sizeChar);
	tbHData = (char*) calloc(tbHDataSize,sizeChar);
	//================fim aloca host tbHPosData/tbHContPadHash/tbHSizePadHash/tbHIdxSizePadHash/tbHData
	
	
	vecPermu1_1();
	
	size_t sizeChartb = tbHDataSize * sizeof(char);	
	size_t sizeInttb = M * sizeof(int);
	

	cudaError_t err = cudaSuccess;
	//=========== aloca device d_tbHData/d_tbHContPadHash/d_tbHPosData/d_tbHSizePadHash/d_tbHIdxSizePadHash
	err = cudaMalloc((void **)&d_tbHData, sizeChartb);
    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to allocate device vector d_tbHData (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }

	err = cudaMalloc((void **)&d_tbHContPadHash, sizeInttb);
    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to allocate device vector d_tbHContPadHash (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }

	err = cudaMalloc((void **)&d_tbHPosData, sizeInttb);
    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to allocate device vector d_tbHPosData (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }

	err = cudaMalloc((void **)&d_tbHSizePadHash, sizeInttb);
    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to allocate device vector d_tbHSizePadHash (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }

	err = cudaMalloc((void **)&d_tbHIdxSizePadHash, sizeInttb);
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

	#ifdef VERBOSE
		/*tbHData = "\000";
		
		cout<<"strlen(tbHData): "<<strlen(tbHData)<<"\n";
		for (int i =0;i< strlen(tbHData) ;i++) {
			cout<<"tbHData["<<i<<"]"<< tbHData[i]<<"\n";
		}
		*/
		/*cout<<">>>>>>>padroes: "<<endl;
		for(int i=0 ; i<padroes.size() ; i++){

			cout<<">>>>>>>>>>>>>>>" <<padroes[i]<<endl;
		}*/
		//cout<<">>>>>>>>>>> m: "<< m <<endl; 
		//cout<<">>>>>>>>>>> nP: "<< nP <<endl; 
		//cout<<">>>>>>>>>>> M: "<< M <<endl; 
		//cout<<">>>>>>>>>>> B: "<< B <<endl; 
		//tabelaIdxHash();
		//cout<< "crash malloc"<<"\n";
		//cout<< "crash vecPermu"<<"\n";
		//TabelaHash();	
		//cout<< ">>>>>>>>>>>tabelaidx.size(): "<<tabelaidx.size() <<endl;	
		//tabelaShift();
		//cout<< ">>>>>>>>>>>tabelaSHIFT: "<<tbShift.size() <<endl;	
		cout<< "Tabelas inicializadas........................... " <<endl;	
	#endif
	 
	return 1;

}

int WMGPUInspection::TmhMenorPadrao(){
	
    std::vector<int> sizePadroes;
    for (int i = 0; i <padroes.size() ; ++i) {
        sizePadroes.push_back(padroes[i].size());
    }
    auto minElem = std::min_element(std::begin(sizePadroes), std::end(sizePadroes));
    //std::cout<<minElem.operator*()+"\n"<<std::endl;

   
    return minElem.operator*();
}

int WMGPUInspection::TmhTodosPadroes(){

    int TodosP = m * nP;

    return  TodosP;
}

int WMGPUInspection::BlcStr(){

	double blcStr = log10(2*M)/log10(c);
	//double B = std::ceil(blcStr);
	double Blc = std::round(blcStr);
	return Blc;
}

void WMGPUInspection::tabelaIdxHash(){

	vecPermu();
	
	TabelaHash();


}

void WMGPUInspection::PrecarregaTabelaHash(std::string strTemp, int hash,char* dataTemp){
	
	
	char* dataTemp2;
	//int sizeCharDT2 = B * sizeof(char);
	size_t sizeChar = tbHDataSize * sizeof(char);
	//dataTemp2 = (char*) malloc(sizeCharDT2);
	//dataTemp2 = (char*) calloc(B,sizeCharDT2);
	dataTemp2 = (char*) calloc(tbHDataSize,sizeChar);
	

	for(int j=0;j<padroes.size();j++) {
        bool hashEsgotadoPadraoAtual = false;
		std::string strTemp2 = padroes[j];

		

		int idxInicio2 = 0;
		int idxFim2 = B - 1;

		
		while(idxFim2<strTemp2.length()) {
			std::string subStrPerm2 = strTemp2.substr(idxInicio2,B);

			

			for (int p = 0; p <subStrPerm2.size(); ++p) {
                dataTemp2[p] = subStrPerm2[p];
                //cout<<dataTemp2[p];
			}

			

			int hash2 = 0;
            for (int i = 0; i < strlen(dataTemp); i++) {
                hash2 = hash2 + dataTemp2[i] * (c ^ (i));
                hash2 = hash2 % M;
			}
			
			

			if(hash == hash2   ) {//if(hash == hash2 && !(hashEsgotado(hash))  ) {

                if(!hashEsgotadoPadraoAtual) {
                    if (!strTemp.compare(strTemp2)) {

							

							int posIn = 0;
							int min = strlen(tbHData);
							
							cout<<" strlen(tbHData): "<<min<<endl;
							
                            posIn = min;
                            int max = strTemp.size() + strlen(tbHData);
                            int idx = 0;
							cout << "\n";

							
							
							//cout<<"min: "<<min<<"\n";
							//cout<<"max: "<<max<<"\n";
							for (int d = min; d < max; d++) {
								//if( strTemp[idx] != '\0'){
									tbHData[d] = strTemp[idx];
									idx = idx + 1;
									cout << "[" << d << "]: " << tbHData[d] << '\n';
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
                            cout << "tbHSizePadHash[" << countSizePadHash << "]: " << tbHSizePadHash[countSizePadHash]
                                 << "  ";


                            tbHIdxSizePadHash[hash] = countSizePadHash;
                            cout << "tbHIdxSizePadHash[" << hash << "]: " << tbHIdxSizePadHash[hash] << "\n";

                            hashEsgotadoPadraoAtual = true;
                            countSizePadHash++;
					}else{
						int posIn = 0;
                        int min = strlen(tbHData);

                        posIn = min;
                        int max = strTemp2.size() + strlen(tbHData);
                        int idx = 0;
                        cout << "\n";
						
						//cout<<"min: "<<min<<"\n";
						//cout<<"max: "<<max<<"\n";
                        for (int d = min; d < max; d++) {
							//if(strTemp2[idx] != '\0'){
								tbHData[d] = strTemp2[idx];
								idx = idx + 1;
								cout << "[" << d << "]: " << tbHData[d] << '\n';
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
                        cout << "tbHSizePadHash[" << countSizePadHash << "]: " << tbHSizePadHash[countSizePadHash]
                             << "  ";

                        
                        //if(tbHIdxSizePadHash[hash] < 0) {
                        //    tbHIdxSizePadHash[hash] = countSizePadHash;
                        //    cout << "tbHIdxSizePadHash[" << hash << "]: " << tbHIdxSizePadHash[hash] << "\n";
                        //}

                        hashEsgotadoPadraoAtual = true;
                        countSizePadHash++;
					}
				}
			}
			

			if (idxInicio2==idxFim2){
                idxFim2 = idxFim2 + 1;
                idxInicio2 = idxFim2;
            }else{
                idxInicio2 = idxInicio2 + 1;
                idxFim2 = idxFim2 + 1;
            }

		}
		

		if(j == padroes.size()-1){
            arrHashEsgotados.push_back(hash);
        }

	
	}
	
	//delete[] dataTemp2;
	free(dataTemp2);
}

bool WMGPUInspection::hashEsgotado(int hash){


    if (std::find(std::begin(arrHashEsgotados), std::end(arrHashEsgotados), hash) != std::end(arrHashEsgotados)){
        return true;
    }else{
        return false;
    }

}

void WMGPUInspection::vecPermu1_1(){

	char* dataTemp;
	//int sizeCharDT = B * sizeof(char);
	size_t sizeChar = tbHDataSize * sizeof(char);
	//dataTemp = (char*) malloc(sizeCharDT);
	//dataTemp = (char*) calloc(B,sizeCharDT);
	dataTemp = (char*) calloc(tbHDataSize,sizeChar);
    //vecpermu = std::vector<std::vector<std::string>>(nP,std::vector<std::string>());

	
	//tabelaHASH_ = std::vector<std::vector<std::string>> (M,std::vector<std::string>()); //2*nP

    for (int i = 0; i < padroes.size() ; ++i) {
        std::string strTemp = padroes[i];
		std::string subStrPerm;
		
        int idxInicio = 0;
		int idxFim = B -1;
		
		//cout<<"idxInicio: "<<idxInicio<<"\n";
		//cout<<"idxFim: "<<idxFim<<"\n";

		std::cout <<"padrao: "<<strTemp<<std::endl;
		
        while(idxFim<strTemp.length()){
			
			subStrPerm = strTemp.substr(idxInicio,B);
			//cout<<"subStrPerm: "<<subStrPerm<<std::endl;
			for (int p = 0; p <subStrPerm.size(); ++p) {
				//if(subStrPerm[p] != '\0'){
                	dataTemp[p] = subStrPerm[p];
					cout<<dataTemp[p];
				//}
			}
			

			int hash = 0;
            for (int i = 0; i < strlen(dataTemp); i++) {
                hash = hash + dataTemp[i] * (c ^ (i));
                hash = hash % M;
			}
			
			//cout<<"hash: "<<hash<<std::endl;
			
			if(!(hashEsgotado(hash))){
                PrecarregaTabelaHash(strTemp, hash,dataTemp);
			}
			
			
			
			//PrecarregaTabelaHash(strTemp, hash,dataTemp);
			//PrecarregaTabelaHash(subStrPerm,i);

            if (idxInicio==idxFim){
                idxFim = idxFim + 1;
                idxInicio = idxFim;
            }else{
                idxInicio = idxInicio + 1;
                idxFim = idxFim + 1;
            }

        }
		
    }
	//std::cout <<"	padroes.size: "<<padroes.size()<<std::endl;
	//std::cout <<"	tabelaHASH_.size: "<<tabelaHASH_.size()<<std::endl;

	//delete[] dataTemp;
	free(dataTemp);
}

void WMGPUInspection::vecPermu(){

    vecpermu = std::vector<std::vector<std::string>>(nP,std::vector<std::string>());
 
    for (int i = 0; i < padroes.size() ; ++i) {
        std::string strTemp = padroes[i];
        std::string subStrPerm;

        int idxInicio = 0;
        int idxFim = B -1;
        while(idxFim<strTemp.length()){
            

            subStrPerm = strTemp.substr(idxInicio,B);

            


            if (idxInicio==idxFim){
                
               vecpermu[i].push_back(subStrPerm);
                idxFim = idxFim + 1;
                idxInicio = idxFim;
            }else{
                
                vecpermu[i].push_back(subStrPerm);
               
                idxInicio = idxInicio + 1;
                idxFim = idxFim + 1;

            }

        }

    }


}

void WMGPUInspection::TabelaHash(){
	
	int vpSize = 0;
	for(int j= 0; j< vecpermu.size();j++){
		vpSize = vpSize + vecpermu[j].size();
 	}

 	tabelaidx = std::vector<std::vector<std::string>> (vpSize, std::vector<std::string>());

 	for (int k = 0; k < vecpermu.size(); ++k) {
        	int len  = vecpermu[k].size();
        	for (int i = 0; i < len ; ++i) {
            		int h  = Hash( vecpermu[k].at(i) ,c,M);
            		std::string str = vecpermu[k].at(i);
            		if(h+1<=tabelaidx.size()) {
                		if (std::find(tabelaidx[h].begin(),tabelaidx[h].end(),str) == tabelaidx[h].end() ){
                    			tabelaidx[h].push_back(str);
                		}

            		}else{
                		tabelaidx.resize(h + 1);

                		tabelaidx[h].push_back(str);

            		}

        	}
		
	}

	int sZ = tabelaidx.size()-1;
   	if (tabelaidx[sZ].empty()){
        	tabelaidx[sZ].push_back("*");
	}else{
		tabelaidx.resize(sZ+2);
		tabelaidx[sZ+1].push_back("*");
	}

}

int WMGPUInspection::Hash(std::string strBloco, int c, int M){
    
    int hash = 0;
    for (int i = 0; i <strBloco.length() ; ++i) {
        hash = hash + strBloco[i] * pow(c,i);
		hash = hash % M;
    }

    return hash;
}

void WMGPUInspection::tabelaShift(){
	
    tbShift =  std::vector<int>(tabelaidx.size(),int());
    
    for (int b1 = 0; b1 <tabelaidx.size() ; ++b1) {
        if (!tabelaidx[b1].empty()) {
            for (int b2 = 0; b2 < tabelaidx[b1].size(); ++b2) {
                std::string blocoStr = tabelaidx[b1].at(b2);
                std::vector<int> min;
               
                for (int p = 0; p < padroes.size(); ++p) {
                    

                    std::string pdr;
                    std::vector<char> writable(padroes.at(p).begin(), padroes.at(p).end());
                    writable.push_back('\0');
                    pdr = &*writable.begin();
                    std::string s;

                    int q=0;

                    
                    int idxInicio = 0;
                    int idxFim = B - 1;
                    while (idxFim < pdr.length()){
                        
                        s = pdr.substr(idxInicio,B);
                        if (!blocoStr.find(s)){
                            q = idxFim + 1;

                        }
                        if (idxInicio == idxFim){
                            idxFim = idxFim + 1;
                            idxInicio = idxFim;
                        }else{
                            idxInicio = idxInicio+1;
                            idxFim = idxFim + 1;
                        }
                        if (idxFim == pdr.length() && q > 0){
                            while ((m - q) < 0) {
                                q = q - 1;
                            }

                            min.push_back(m - q);
                        }
                    }
                    

                } 
                if (min.empty()){
                    tbShift.insert(tbShift.begin()+b1,m - B +1);
                    tbShift.erase(tbShift.begin()+b1+1);
		    /*
		    if(b1 == 10542){
		    	#ifdef VERBOSE
				//cout<< ">>>>>>>>>>>tbShift[10542]: "<<tbShift[10542] <<endl;	
	            	#endif
		    }
		    */
                }else {
                    std::vector<int>::iterator result = std::min_element(std::begin(min), std::end(min));
                    tbShift.insert(tbShift.begin() + b1, result.operator*());
                    tbShift.erase(tbShift.begin() + b1 + 1);
		   /* 
		    if(b1 == 10542){
		    	#ifdef VERBOSE
				//cout<< ">>>>>>>>>>>tbShift[10542]: "<<tbShift[10542] <<endl;	
	            	#endif
		    }
		  */
                }
                
            }
        }


    }


}

std::vector<int> WMGPUInspection::AdcTodosPadroesTabela(std::string str){

	std::vector<int> listaPadroes;
    	for (int k = 0; k <padroes.size() ; ++k) {
        	if (std::find(vecpermu[k].begin(),vecpermu[k].end(),str) != vecpermu[k].end() ){

            		listaPadroes.push_back(k);
        	}
    	}
	return listaPadroes;
}

void WMGPUInspection::MatchPadroes(std::vector<std::string> listPotenPadr, std::string subData){

    for (unsigned t = 0; t <listPotenPadr.size() ; ++t) { 
        bool match = true;
        std::string str =listPotenPadr.at(t); 
        int _final = subData.size()-1;
        //int _final = dataTemp.size()-1;
        for (int ch = listPotenPadr.at(t).length()-1; ch>=0 ; --ch) { 
		if(_final>=0){
            		if( str.at(ch) ==  subData.at(_final)) {
                		_final = _final - 1;
            		}else{
                		match = false;
                		break;
            		}
		}else{
			match= false;
			break;
		}		

        }

        if (match){
            //int posicao = _final+1;
    	    #ifdef VERBOSE
            		//std::cout<<"\r"<<">>>>>>>>>>>>  Na posicao "<<posicao<<", ha um match com o padrao: "<<listPotenPadr.at(t)<<std::endl;
    	    #endif
		
        }
    }
}
