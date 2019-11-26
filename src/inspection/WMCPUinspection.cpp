#include "WMCPUinspection.h"



WMCPUInspection::WMCPUInspection(){

}

WMCPUInspection::~WMCPUInspection(){

}

void WMCPUInspection::exec(std::shared_ptr<Packet> pkt){
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
				//nextInput = false;
				#ifdef VERBOSE
						//std::cout<<">>>>>>>>>>>>>>>>payload_[ ]: " <<reinterpret_cast<char*>( pkt.get()->payload_) <<std::endl;
						//std::cout<< "size: " << pkt.get()->size_payload_ <<std::endl;
				#endif
				//this->excWuManberCore1_1( reinterpret_cast<char*>(pkt.get()->payload_) );
				std::string dataTemp = reinterpret_cast<char*>(pkt.get()->payload_);
					
				int N = dataTemp.length();

        		int pos = 0;
    		

        		//int pref = m - B2;
				
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

/*
void WMCPUInspection::exec(std::shared_ptr<Packet> pkt){

	    //std::cout<<"Inicio exec" <<std::endl;

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
				//nextInput = false;
				#ifdef VERBOSE
						//std::cout<<">>>>>>>>>>>>>>>>payload_[ ]: " <<reinterpret_cast<char*>( pkt.get()->payload_) <<std::endl;
						//std::cout<< "size: " << pkt.get()->size_payload_ <<std::endl;
				#endif
				//this->excWuManberCore1_1( reinterpret_cast<char*>(pkt.get()->payload_) );
				std::string dataTemp = reinterpret_cast<char*>(pkt.get()->payload_);
					
				int N = dataTemp.length();

        		int pos = m;
    		

        		int pref = m - B2;
    		
        		while(pos<=N){
					
            			int tPos_B1 = (pos - B +1) - 1; 
            		
            			int i = Hash(dataTemp.substr(tPos_B1,B),c,M);
					
            			if (tbShift[i] == 0){
						
							//MatchPadroes1_1(i,dataTemp.substr(0,pos) );
							std::string subData = dataTemp.substr(0,pos);
							int sbDSz = subData.size();
							int tbHSz = tabelaHASH_[i].size();
							for (unsigned t = 0; t <tbHSz ; ++t) { 
								bool match = true;
								std::string str =tabelaHASH_[i].at(t); 
								int _final = sbDSz-1;
								//int _final = dataTemp.size()-1;
								for (int ch = tabelaHASH_[i].at(t).length()-1; ch>=0 ; --ch) { 
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
									int posicao = _final+1;
									#ifdef VERBOSE
											//std::cout<<"\r"<<">>>>>>>>>>>>  Na posicao "<<posicao<<", ha um match com o padrao: "<<tabelaHASH_[hash].at(t)<<std::endl;
									#endif
								
								}
							}
                			pos++;
            			}else{
                			pos = pos + tbShift[i];
            			}

        		}
		
		
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
*/

void WMCPUInspection::excWuManberCore(std::string  nextData){

			std::cout<<"Inicio excWuManberCore" <<std::endl;

        	std::vector<std::vector<std::string>> tabelaHASH = std::vector<std::vector<std::string>> (tbShift.size(),std::vector<std::string>());
			#ifdef VERBOSE
				//cout<< ">>>>>>>>>>>tabelaHASH: "<<tabelaHASH.size() <<endl;	
			#endif
	
        	std::vector<std::vector<std::string>> tabelaPREFIX = std::vector<std::vector<std::string>>(tbShift.size(),std::vector<std::string>());
			#ifdef VERBOSE
				//cout<< ">>>>>>>>>>>tabelaPREFIX: "<<tabelaPREFIX.size() <<endl;	
			#endif


			std::string dataTemp = nextData;
			#ifdef VERBOSE
				//std::cout<<"dataTemp: "<<dataTemp <<std::endl;
			#endif
			int N = dataTemp.length();
    			#ifdef VERBOSE
    				//cout <<">>>>>>>>>>>>>N: "<<N<< endl;
    			#endif


        		int pos = m;
    			#ifdef VERBOSE
    				//cout <<">>>>>>>>>>>>>pos: "<<pos<< endl;
    			#endif

        		int pref = m - B2;
    			#ifdef VERBOSE
    				//cout <<">>>>>>>>>>>>>pref: "<<pref<< endl;
    			#endif
        		while(pos<=N){
    				#ifdef VERBOSE
    					//cout <<"      while>>>>>>>>>>>>>pos: "<<pos<< endl;
    				#endif
            			int tPos_B1 = (pos - B +1) - 1; 
            			//int tPos = (pos) - 1;
            			//int i = Hash(data.substr(tPos_B1,B),c,M);
            			int i = Hash(dataTemp.substr(tPos_B1,B),c,M);
    				#ifdef VERBOSE
    					//cout <<"      while>>>>>>>>>>>>>Hash i: "<<i<< endl;
    				#endif
            			if (tbShift[i] == 0){//tbShift[i]
		    			
		    			#ifdef VERBOSE
						//cout<< ">>>>>>>>>>>tbShift: "<<tbShift[i] <<endl;	
	            			#endif
		    				
                			if( !(tabelaHASH[i].empty()) ){
                    				if (pref == 0){
                        				//std::cout<<"Sem prefixos"<<std::endl;
                    				}else{
                        				int tPos_B_1 = (pos - B2 -1);
                        				int tPos_B = (pos - B2) - 1;
                        				//int j = Hash(data.substr(tPos_B_1,tPos_B),c, M);
                        				int j = Hash(dataTemp.substr(tPos_B_1,tPos_B),c, M);
                        				//std::vector<int> listaPadroes = AdcTodosPadroesTabela(data.substr(tPos_B_1,B),B,nP,padroes);

                        				//AdcTodosPadroesTabela(data.substr(tPos_B_1,B));
                        				std::vector<int> listaPadroes;
                        				listaPadroes = AdcTodosPadroesTabela(dataTemp.substr(tPos_B_1,B));

                        				for (int lp = 0; lp < listaPadroes.size(); ++lp) {
                            					tabelaPREFIX[j].push_back(padroes[ listaPadroes[lp] ]);
                        				}
						
										std::string subData = dataTemp.substr(0,pos);
										std::vector<std::string> listPotenPadr = tabelaPREFIX[j]; // é carregada quando pref  !=0  e tabelaHASH já tem algo em [i]
                        				MatchPadroes(listPotenPadr,subData);

										//listaPadroes.clear();
										//subData.clear();
										//listPotenPadr.clear();
                    				}
                			}else{
									std::vector<int> listaPadroes;	
                    				listaPadroes = AdcTodosPadroesTabela(dataTemp.substr(tPos_B1,B));
                    				
									for (int lp = 0; lp < listaPadroes.size(); ++lp) {
													tabelaHASH[i].push_back(padroes[ listaPadroes[lp] ]);
                    				}

									std::string subData = dataTemp.substr(0,pos);
									std::vector<std::string> listPotenPadr = tabelaHASH[i];
                    				MatchPadroes(listPotenPadr,subData);
				

									//listaPadroes.clear();
									//subData.clear();
									//listPotenPadr.clear();
                			}		
                			pos++;
            			}else{
                			pos = pos + tbShift[i];
            			}

        		}
		
		//data.clear();	 
  
}

void WMCPUInspection::excWuManberCore1_1(std::string  nextData){

			std::cout<<"Inicio excWuManberCore1_1" <<std::endl;
        	//std::vector<std::vector<std::string>> tabelaHASH = std::vector<std::vector<std::string>> (tbShift.size(),std::vector<std::string>());
			#ifdef VERBOSE
				//cout<< ">>>>>>>>>>>WuManberCore1_1: " <<endl;	
			#endif
	
        	//std::vector<std::vector<std::string>> tabelaPREFIX = std::vector<std::vector<std::string>>(tbShift.size(),std::vector<std::string>());
			#ifdef VERBOSE
				//cout<< ">>>>>>>>>>>tabelaPREFIX: "<<tabelaPREFIX.size() <<endl;	
			#endif


			std::string dataTemp = nextData;
			//std::string dataTemp = "ABEDEDABG";
			#ifdef VERBOSE
				//std::cout<<"dataTemp: "<<dataTemp <<std::endl;
			#endif
			int N = dataTemp.length();
    			#ifdef VERBOSE
    				//cout <<">>>>>>>>>>>>>N: "<<N<< endl;
    			#endif


        		int pos = m;
    			#ifdef VERBOSE
    				//cout <<">>>>>>>>>>>>>pos: "<<pos<< endl;
    			#endif

        		int pref = m - B2;
    			#ifdef VERBOSE
    				//cout <<">>>>>>>>>>>>>pref: "<<pref<< endl;
    			#endif
        		while(pos<=N){
						#ifdef VERBOSE
							//cout <<"      while>>>>>>>>>>>>>pos: "<<pos<< endl;
						#endif
            			int tPos_B1 = (pos - B +1) - 1; 
            			//int tPos = (pos) - 1;
            			//int i = Hash(data.substr(tPos_B1,B),c,M);
            			int i = Hash(dataTemp.substr(tPos_B1,B),c,M);
						#ifdef VERBOSE
							//cout <<"      while>>>>>>>>>>>>>Hash i: "<<i<< endl;
						#endif
            			if (tbShift[i] == 0){
							//tbShift[i]
		    			
							#ifdef VERBOSE
								//cout<< ">>>>>>>>>>>tbShift["<<i<<"]: "<<tbShift[i] <<endl;	
							#endif
							//std::cout<<"subStr: "<<dataTemp.substr(tPos_B1,B)<<std::endl;
							MatchPadroes1_1(i,dataTemp.substr(0,pos));


		    				
                			/* if( !(tabelaHASH[i].empty()) ){
                    				if (pref == 0){
                        				//std::cout<<"Sem prefixos"<<std::endl;
                    				}else{
                        				int tPos_B_1 = (pos - B2 -1);
                        				int tPos_B = (pos - B2) - 1;
                        				//int j = Hash(data.substr(tPos_B_1,tPos_B),c, M);
                        				int j = Hash(dataTemp.substr(tPos_B_1,tPos_B),c, M);
                        				//std::vector<int> listaPadroes = AdcTodosPadroesTabela(data.substr(tPos_B_1,B),B,nP,padroes);

                        				//AdcTodosPadroesTabela(data.substr(tPos_B_1,B));
                        				std::vector<int> listaPadroes;
                        				listaPadroes = AdcTodosPadroesTabela(dataTemp.substr(tPos_B_1,B));

                        				for (int lp = 0; lp < listaPadroes.size(); ++lp) {
                            					tabelaPREFIX[j].push_back(padroes[ listaPadroes[lp] ]);
                        				}
						
										std::string subData = dataTemp.substr(0,pos);
										std::vector<std::string> listPotenPadr = tabelaPREFIX[j]; // é carregada quando pref  !=0  e tabelaHASH já tem algo em [i]
                        				MatchPadroes(listPotenPadr,subData);

										//listaPadroes.clear();
										//subData.clear();
										//listPotenPadr.clear();
                    				}
                			}else{
									std::vector<int> listaPadroes;	
                    				listaPadroes = AdcTodosPadroesTabela(dataTemp.substr(tPos_B1,B));
                    				
									for (int lp = 0; lp < listaPadroes.size(); ++lp) {
													tabelaHASH[i].push_back(padroes[ listaPadroes[lp] ]);
                    				}

									std::string subData = dataTemp.substr(0,pos);
									std::vector<std::string> listPotenPadr = tabelaHASH[i];
                    				MatchPadroes(listPotenPadr,subData);
				

									//listaPadroes.clear();
									//subData.clear();
									//listPotenPadr.clear();
                			} */

                			pos++;
            			}else{
                			pos = pos + tbShift[i];
            			}

        		}
		
		//data.clear();	 
  
}

//
int WMCPUInspection::buildMatchingMachineTeste(std::string rules){
    
    	std::string line;
    	ifstream file(rules.c_str(), std::ifstream::in);
    	maxs_ = 0;
    	while(getline(file,line))
    	{
        	padroes.push_back(line);    
        	maxs_ += line.size();
    	}

    	#ifdef VERBOSE
       	/*cout<<">>>>>>>padroes: "<<endl;
       	for(int i=0 ; i<padroes.size() ; i++){
	
		cout<<">>>>>>>>>>>>>>>" <<padroes[i]<<endl;
	}*/
    	#endif 
	
		
    	m = TmhMenorPadrao();
    	#ifdef VERBOSE
    
    		//cout<<">>>>>>>>>>> m: "<< m <<endl; 
    	#endif
	

    	nP = padroes.size();
    
    	#ifdef VERBOSE
    
    		//cout<<">>>>>>>>>>> nP: "<< nP <<endl; 
    	#endif
	
    	M = TmhTodosPadroes();
    
    	#ifdef VERBOSE 
    		//cout<<">>>>>>>>>>> M: "<< M <<endl; 
    	#endif



    	//c = 94;  

    	B = BlcStr(); 
    	#ifdef VERBOSE 
    		//cout<<">>>>>>>>>>> B: "<< B <<endl; 
    	#endif
    
    	B2 = B;

		#ifdef VERBOSE
			cout<< "Inicializando tabelas........................... " <<endl;	
		#endif
	    
    	//tabelaIdxHash();
		vecPermu1_1();
		TabelaHash();

		#ifdef VERBOSE
			//cout<< ">>>>>>>>>>>tabelaidx.size(): "<<tabelaidx.size() <<endl;	
		#endif

		tabelaShift();

		
		#ifdef VERBOSE
			//cout<< ">>>>>>>>>>>tabelaSHIFT: "<<tbShift.size() <<endl;	
		#endif

			#ifdef VERBOSE
			cout<< "Tabelas inicializadas........................... " <<endl;	
		#endif


		/*
			tabelaHASH = std::vector<std::vector<std::string>> (tbShift.size(),std::vector<std::string>());
		#ifdef VERBOSE
			//cout<< ">>>>>>>>>>>tabelaHASH: "<<tabelaHASH.size() <<endl;	
		#endif
		
			tabelaPREFIX = std::vector<std::vector<std::string>>(tbShift.size(),std::vector<std::string>());
		#ifdef VERBOSE
			//cout<< ">>>>>>>>>>>tabelaPREFIX: "<<tabelaPREFIX.size() <<endl;	
		#endif
		*/
		this->excWuManberCore1_1( "ABEDEDABG" );
		return 1;

}

int WMCPUInspection::buildMatchingMachine1_1(std::string rules){
    
    	std::string line;
    	ifstream file(rules.c_str(), std::ifstream::in);
    	maxs_ = 0;
    	while(getline(file,line))
    	{
        	padroes.push_back(line);    
        	maxs_ += line.size();
    	}

    	#ifdef VERBOSE
       	/*cout<<">>>>>>>padroes: "<<endl;
       	for(int i=0 ; i<padroes.size() ; i++){
	
		cout<<">>>>>>>>>>>>>>>" <<padroes[i]<<endl;
	}*/
    	#endif 
	
		
    	m = TmhMenorPadrao();
    	#ifdef VERBOSE
    
    		//cout<<">>>>>>>>>>> m: "<< m <<endl; 
    	#endif
	

    	nP = padroes.size();
    
    	#ifdef VERBOSE
    
    		//cout<<">>>>>>>>>>> nP: "<< nP <<endl; 
    	#endif
	
    	M = TmhTodosPadroes();
    
    	#ifdef VERBOSE 
    		//cout<<">>>>>>>>>>> M: "<< M <<endl; 
    	#endif



    	//c = 94;  

    	B = BlcStr(); 
    	#ifdef VERBOSE 
    		//cout<<">>>>>>>>>>> B: "<< B <<endl; 
    	#endif
    
    	B2 = B;

		#ifdef VERBOSE
			cout<< "Inicializando tabelas........................... " <<endl;	
		#endif
	    
    	//tabelaIdxHash();
		vecPermu1_1();
		TabelaHash();

		#ifdef VERBOSE
			//cout<< ">>>>>>>>>>>tabelaidx.size(): "<<tabelaidx.size() <<endl;	
		#endif

		tabelaShift();

		
		#ifdef VERBOSE
			//cout<< ">>>>>>>>>>>tabelaSHIFT: "<<tbShift.size() <<endl;	
		#endif

			#ifdef VERBOSE
			cout<< "Tabelas inicializadas........................... " <<endl;	
		#endif


		/*
			tabelaHASH = std::vector<std::vector<std::string>> (tbShift.size(),std::vector<std::string>());
		#ifdef VERBOSE
			//cout<< ">>>>>>>>>>>tabelaHASH: "<<tabelaHASH.size() <<endl;	
		#endif
		
			tabelaPREFIX = std::vector<std::vector<std::string>>(tbShift.size(),std::vector<std::string>());
		#ifdef VERBOSE
			//cout<< ">>>>>>>>>>>tabelaPREFIX: "<<tabelaPREFIX.size() <<endl;	
		#endif
		*/
		 
		return 1;

}

int WMGPUInspection::buildMatchingMachine1_1_1(std::string rules){
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
	//tbHDataSize = 4000000;
	//cout<<"tbHDataSize: "<<tbHDataSize<<"\n";

	arrHashEsgotados = std::vector<int> (tbHDataSize);
	
	

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
	tbHData = (char*)calloc(tbHDataSize, sizeof(char));//tbHData = (char*) calloc(tbHDataSize,sizeChar);
	//================fim aloca host tbHPosData/tbHContPadHash/tbHSizePadHash/tbHIdxSizePadHash/tbHData
	
	
	vecPermu1_1_1();
	
	

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

int WMCPUInspection::buildMatchingMachine(std::string rules){
    
    	std::string line;
    	ifstream file(rules.c_str(), std::ifstream::in);
    	maxs_ = 0;
    	while(getline(file,line))
    	{
        	padroes.push_back(line);    
        	maxs_ += line.size();
    	}

    	#ifdef VERBOSE
       	/*cout<<">>>>>>>padroes: "<<endl;
       	for(int i=0 ; i<padroes.size() ; i++){
	
		cout<<">>>>>>>>>>>>>>>" <<padroes[i]<<endl;
	}*/
    	#endif 
	
		
    	m = TmhMenorPadrao();
    	#ifdef VERBOSE
    
    		//cout<<">>>>>>>>>>> m: "<< m <<endl; 
    	#endif
	

    	nP = padroes.size();
    
    	#ifdef VERBOSE
    
    		//cout<<">>>>>>>>>>> nP: "<< nP <<endl; 
    	#endif
	
    	M = TmhTodosPadroes();
    
    	#ifdef VERBOSE 
    		//cout<<">>>>>>>>>>> M: "<< M <<endl; 
    	#endif



    	//c = 94;  

    	B = BlcStr(); 
    	#ifdef VERBOSE 
    		//cout<<">>>>>>>>>>> B: "<< B <<endl; 
    	#endif
    
    	B2 = B;

		#ifdef VERBOSE
			cout<< "Inicializando tabelas........................... " <<endl;	
		#endif
	    
    	tabelaIdxHash();

		#ifdef VERBOSE
			//cout<< ">>>>>>>>>>>tabelaidx.size(): "<<tabelaidx.size() <<endl;	
		#endif

		tabelaShift();

		
		#ifdef VERBOSE
			//cout<< ">>>>>>>>>>>tabelaSHIFT: "<<tbShift.size() <<endl;	
		#endif

			#ifdef VERBOSE
			cout<< "Tabelas inicializadas........................... " <<endl;	
		#endif


		/*
			tabelaHASH = std::vector<std::vector<std::string>> (tbShift.size(),std::vector<std::string>());
		#ifdef VERBOSE
			//cout<< ">>>>>>>>>>>tabelaHASH: "<<tabelaHASH.size() <<endl;	
		#endif
		
			tabelaPREFIX = std::vector<std::vector<std::string>>(tbShift.size(),std::vector<std::string>());
		#ifdef VERBOSE
			//cout<< ">>>>>>>>>>>tabelaPREFIX: "<<tabelaPREFIX.size() <<endl;	
		#endif
		*/
		 
		return 1;

}

void WMCPUInspection::tabelaShift(){
	
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

int WMCPUInspection::TmhMenorPadrao(){
	
    std::vector<int> sizePadroes;
    for (int i = 0; i <padroes.size() ; ++i) {
        sizePadroes.push_back(padroes[i].size());
    }
    auto minElem = std::min_element(std::begin(sizePadroes), std::end(sizePadroes));
    //std::cout<<minElem.operator*()+"\n"<<std::endl;

   
    return minElem.operator*();
}

int WMCPUInspection::TmhTodosPadroes(){

    int TodosP = m * nP;

    return  TodosP;
}

double WMCPUInspection::BlcStr(){

    	double blcStr = log10(2*M)/log10(c);
    	//double B = std::ceil(blcStr);
    	double Blc = std::round(blcStr);
	return Blc;
}

void WMCPUInspection::tabelaIdxHash(){

    	vecPermu();
	
	#ifdef VERBOSE
		//cout<< ">>>>>>>>>>>>>>>padroes.length: " <<padroes.size() <<endl;	
	        //cout<< "data.length: "<< data.length()<< endl;
		//cout<< ">>>>>>>>>>>>>nP: "<<nP <<endl;	
		//cout<< ">>>>>>>>>>>>vecpermu: "<<vecpermu.size() <<endl;	
		//cout<< ">>>>>>>>>>>tabelaHash: "<<tabelaidx.size() <<endl;	
	
	#endif

	TabelaHash();
	
	
}

void WMCPUInspection::PrecarregaTabelaHash(std::string subStr,int idxPadrao){
		
		//std::cout <<"	PrecarregatabelaHASH...."<<std::endl;
		

		int i = Hash(subStr,c,M);
		//std::cout <<"subStr: "<<subStr<<std::endl;
		//std::cout <<"["<<idxPadrao<<"] Hash: "<<i<<std::endl;
		/* std::vector<int> listaPadroes;	
		listaPadroes = AdcTodosPadroesTabela(subStr);
		
		for (int lp = 0; lp < listaPadroes.size(); ++lp) {
						tabelaHASH_[i].push_back(padroes[ listaPadroes[lp] ]);
						std::cout <<"tabelaHASH["<< i <<"].push_back("<< padroes[ listaPadroes[lp]] << ")" << std::endl;
		} */
		//for (unsigned t = 0; t <tabelaHASH_[i].size() ; ++t) { 
			if ( !(std::find(tabelaHASH_[i].begin(),tabelaHASH_[i].end(),padroes[ idxPadrao ]) != tabelaHASH_[i].end()) ){

							//listaPadroes.push_back(k);
							//std::cout <<"tabelaHASH_["<< i <<"].push_back("<< padroes[ idxPadrao ] << ")" << std::endl;
							tabelaHASH_[i].push_back(padroes[ idxPadrao ]);
			}
		
		//}

		//std::string subData = dataTemp.substr(0,pos);
		//std::vector<std::string> listPotenPadr = tabelaHASH[i];

		//std::cout <<"	FIM PrecarregatabelaHASH...."<<std::endl;

}

void WMCPUInspection::vecPermu1_1(){

    vecpermu = std::vector<std::vector<std::string>>(nP,std::vector<std::string>());

	
	tabelaHASH_ = std::vector<std::vector<std::string>> (M,std::vector<std::string>()); //2*nP

    for (int i = 0; i < padroes.size() ; ++i) {
        std::string strTemp = padroes[i];
        std::string subStrPerm;

        int idxInicio = 0;
        int idxFim = B -1;
		
		//std::cout <<"	padrao: "<<strTemp<<std::endl;
        while(idxFim<strTemp.length()){
            

            subStrPerm = strTemp.substr(idxInicio,B);

			
			PrecarregaTabelaHash(subStrPerm,i);

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
	//std::cout <<"	padroes.size: "<<padroes.size()<<std::endl;
	//std::cout <<"	tabelaHASH_.size: "<<tabelaHASH_.size()<<std::endl;
}

void WMGPUInspection::PrecarregaTabelaHash1_1_1(std::string strTemp, int hash,char* dataTemp){
	
	if(indexDebug == 762443){
		std::cout <<"PrecarregaTabelaHash error "<<std::endl;
	}

	//char* dataTemp2;//char* dataTemp2;
	//int sizeCharDT2 = B * sizeof(char);
	size_t sizeChar = B * sizeof(char);//size_t sizeChar = tbHDataSize * sizeof(char);
	//dataTemp2 = (char*) malloc(sizeCharDT2);
	//dataTemp2 = (char*) calloc(B,sizeCharDT2);
	dataTemp2 = (char*) calloc(B,sizeof(char));//dataTemp2 = (char*) calloc(tbHDataSize,sizeChar);
	
	int padroes_size = padroes.size();
	for(int j=0; j < padroes_size ; j++) {

		
		if(indexDebug == 762443){
			std::cout <<"for index j: "<<j<<std::endl;
		}
		

        bool hashEsgotadoPadraoAtual = false;
		std::string strTemp2 = padroes[j];

		

		int idxInicio2 = 0;
		int idxFim2 = B - 1;

		
		while(idxFim2<strTemp2.length()) {

			if(indexDebug == 753488){
				std::cout <<"while begin error "<<std::endl;
			}
			
			std::string subStrPerm2 = strTemp2.substr(idxInicio2,B);

			
			
			int contdataTemp2 = 0;
			for (int p = 0; p <subStrPerm2.size(); ++p) {
                dataTemp2[p] = subStrPerm2[p];
				//cout<<dataTemp2[p];
				contdataTemp2++;

				if(indexDebug == 753488){
					std::cout <<"while error "<<std::endl;
					std::cout <<"  subStrPerm2:"<<subStrPerm2<<std::endl;
					std::cout <<"  dataTemp2["<<p<<"]:"<<dataTemp2[p]<<std::endl;
					std::cout <<"  contdataTemp2++:"<<contdataTemp2<<std::endl;
				}
			}

			

			int hash2 = 0;
            for (int i = 0; i < contdataTemp2; i++) {//for (int i = 0; i < strlen(dataTemp); i++) {
				hash2 = hash2 + dataTemp2[i] * (c ^ (i));
				
				if(indexDebug == 753488){
					std::cout <<"for error "<<std::endl;
					std::cout <<"  hash2:"<<hash2<<std::endl;
					std::cout <<"  dataTemp2["<<i<<"]:"<<dataTemp2[i]<<std::endl;
				
				}

				hash2 = hash2 % M;

				if(indexDebug == 753488){
					std::cout <<"  mod:"<<hash2<<std::endl;
				
				}
				
			}
			
			

			if(hash == hash2   ) {//if(hash == hash2 && !(hashEsgotado(hash))  ) {

                if(!hashEsgotadoPadraoAtual) {
                    if (!strTemp.compare(strTemp2)) {

							

							int posIn = 0;
							int min = conttbHData;//int min = strlen(tbHData);
							
							cout<<" strlen(tbHData): "<<min<<endl;
							
                            posIn = min;
                            int max = strTemp.size() + conttbHData;//int max = strTemp.size() + strlen(tbHData);
                            int idx = 0;
							cout << "\n";

							
							
							//cout<<"min: "<<min<<"\n";
							//cout<<"max: "<<max<<"\n";
							for (int d = min; d < max; d++) {
								//if( strTemp[idx] != '\0'){
									tbHData[d] = strTemp[idx];
									idx = idx + 1;
									cout << "[" << d << "]: " << tbHData[d] << '\n';
									conttbHData = conttbHData + 1;

									indexDebug =d;
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

							if(indexDebug == 753488){
								std::cout <<"error "<<std::endl;
							}

                            hashEsgotadoPadraoAtual = true;
                            countSizePadHash++;
					}else{
						int posIn = 0;
                        int min = conttbHData;//int min = strlen(tbHData);

                        posIn = min;
                        int max = strTemp2.size() + conttbHData;//int max = strTemp2.size() + strlen(tbHData);
                        int idx = 0;
                        cout << "\n";
						
						//cout<<"min: "<<min<<"\n";
						//cout<<"max: "<<max<<"\n";
                        for (int d = min; d < max; d++) {
							//if(strTemp2[idx] != '\0'){
								tbHData[d] = strTemp2[idx];
								idx = idx + 1;
								cout << "[" << d << "]: " << tbHData[d] << '\n';
								conttbHData = conttbHData + 1;

								indexDebug =d;
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

						
						if(indexDebug == 753488){
							std::cout <<"else error "<<std::endl;
						}
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
			
			if(indexDebug == 753488){
				std::cout <<"idxInicio2==idxFim2 end error "<<std::endl;
				
				std::cout <<idxFim2<<"<" << strTemp2.length() <<std::endl;
			}
			

		}
		
		if(indexDebug == 753488){
			std::cout <<"while end error "<<std::endl;
		}

		if(j == padroes.size()-1){
			arrHashEsgotados.push_back(hash);
			
			if(indexDebug == 753488){
				std::cout <<"arrHashEsgotados.push_back end error "<<std::endl;
			}
        }

		if(indexDebug == 753488){
			std::cout <<"numero padroes: "<<padroes.size()<<std::endl;
			std::cout <<"index j:"<<j<<std::endl;
		}
	}

	if(indexDebug == 753488){
		std::cout <<"for end error "<<std::endl;
	}
	
	//delete[] dataTemp2;
	//free(dataTemp2);
}

void WMGPUInspection::vecPermu1_1_1(){

	//char* dataTemp;//char* dataTemp;
	//int sizeCharDT = B * sizeof(char);
	size_t sizeChar = B * sizeof(char);//size_t sizeChar = tbHDataSize * sizeof(char);
	//dataTemp = (char*) malloc(sizeCharDT);
	//dataTemp = (char*) calloc(B,sizeCharDT);
	dataTemp = (char*)calloc(B, sizeof(char));//dataTemp = (char*) calloc(tbHDataSize,sizeChar);
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
			int contDataTemp = 0;

			
			for (int p = 0; p <subStrPerm.size(); ++p) {
				//if(subStrPerm[p] != '\0'){
                	dataTemp[p] = subStrPerm[p];
					cout<<dataTemp[p];
					contDataTemp++;
				//}
			}
			

			int hash = 0;
            for (int i = 0; i < contDataTemp; i++) {//for (int i = 0; i < strlen(dataTemp); i++) {
                hash = hash + dataTemp[i] * (c ^ (i));
                hash = hash % M;
			}
			
			//cout<<"hash: "<<hash<<std::endl;
			
			if(!(hashEsgotado(hash))){
                PrecarregaTabelaHash1_1_1(strTemp, hash,dataTemp);
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
	free(dataTemp2);

	std::cout << "Fim inicializacao de tabelas" << std::endl;
}

void WMCPUInspection::vecPermu(){

    vecpermu = std::vector<std::vector<std::string>>(nP,std::vector<std::string>());

	
	//tabelaHASH_ = std::vector<std::vector<std::string>> (M,std::vector<std::string>()); //2*nP

    for (int i = 0; i < padroes.size() ; ++i) {
        std::string strTemp = padroes[i];
        std::string subStrPerm;

        int idxInicio = 0;
        int idxFim = B -1;
		
		//std::cout <<"	padrao: "<<strTemp<<std::endl;
        while(idxFim<strTemp.length()){
            

            subStrPerm = strTemp.substr(idxInicio,B);

			
			//PrecarregaTabelaHash(subStrPerm,i);

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
	//std::cout <<"	padroes.size: "<<padroes.size()<<std::endl;
	//std::cout <<"	tabelaHASH_.size: "<<tabelaHASH_.size()<<std::endl;
}

void WMCPUInspection::TabelaHash(){
	
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

void WMCPUInspection::readfilesPadroes(std::string input){


    std::vector<std::string> strFiles;
    std::string s;
    char out;
    std::fstream fs(input,std::fstream::in);
    if (fs.is_open()) {
        while (!fs.eof() &&  (out = fs.get()) ) {
            //fs >> std::noskipws>>out;
            if(out == '\n' || out=='\377'){
                strFiles.push_back(s);
                s="";
            }else{
                s+=out;
            }
            std::cout << out;
        }
    }
    fs.close();


}

void WMCPUInspection::readfilesData(std::string pkt){


    std::vector<std::string> strFiles;
    std::string s;
    char out;
    std::fstream fs(pkt,std::fstream::in);
    if (fs.is_open()) {
        while (!fs.eof() &&  (out = fs.get()) ) {
            //fs >> std::noskipws>>out;
            if(out == '\n' || out=='\377'){
                strFiles.push_back(s);
                s="";
            }else{
                s+=out;
            }
            //std::cout << out;
        }
    }
    fs.close();

}


int WMCPUInspection::Hash(std::string strBloco, int c, int M){
    
    int hash = 0;
    for (int i = 0; i <strBloco.length() ; ++i) {
        hash = hash + strBloco[i] * pow(c,i);
		hash = hash % M;
    }

    #ifdef VERBOSE
	//std::cout<<"   >>>>c: "<<c<<std::endl;
    #endif 
    #ifdef VERBOSE
	//std::cout<<"   >>>>M: "<<M<<std::endl;
    #endif 
    #ifdef VERBOSE
	//std::cout<<"   >>>>Hash: "<<hash<<std::endl;
    #endif
 
    //hash  = hash % M;
    #ifdef VERBOSE
	//std::cout<<"   >>>>has % M: "<<hash<<std::endl;
    #endif 
    return hash;
}

std::vector<int> WMCPUInspection::AdcTodosPadroesTabela(std::string str){

	std::vector<int> listaPadroes;
    	for (int k = 0; k <padroes.size() ; ++k) {
        	if (std::find(vecpermu[k].begin(),vecpermu[k].end(),str) != vecpermu[k].end() ){

            		listaPadroes.push_back(k);
        	}
    	}
	return listaPadroes;
}

void WMCPUInspection::MatchPadroes(std::vector<std::string> listPotenPadr, std::string subData){

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
            int posicao = _final+1;
    	    #ifdef VERBOSE
            		//std::cout<<"\r"<<">>>>>>>>>>>>  Na posicao "<<posicao<<", ha um match com o padrao: "<<listPotenPadr.at(t)<<std::endl;
    	    #endif
		
        }
    }
}


void WMCPUInspection::MatchPadroes1_1(int hash, std::string subData){
	//std::cout<<"subData: "<<subData<<std::endl;
	
    for (unsigned t = 0; t <tabelaHASH_[hash].size() ; ++t) { 
        bool match = true;
        std::string str =tabelaHASH_[hash].at(t); 
        int _final = subData.size()-1;
        //int _final = dataTemp.size()-1;
        for (int ch = tabelaHASH_[hash].at(t).length()-1; ch>=0 ; --ch) { 
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
            int posicao = _final+1;
    	    #ifdef VERBOSE
            		//std::cout<<"\r"<<">>>>>>>>>>>>  Na posicao "<<posicao<<", ha um match com o padrao: "<<tabelaHASH_[hash].at(t)<<std::endl;
    	    #endif
		
        }
    }
}