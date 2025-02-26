// FOR BC: nvcc bc_dsl_v2.cu -arch=sm_60 -std=c++14 -rdc=true # HW must support CC 6.0+ Pascal or after
#include "pageRankDSLV2.h"

void Compute_PR(graph& g,float beta,float delta,int maxIter,
  float* pageRank)

{
  // CSR BEGIN
  int V = g.num_nodes();
  int E = g.num_edges();

  printf("#nodes:%d\n",V);
  printf("#edges:%d\n",E);
  int* edgeLen = g.getEdgeLen();

   FILE* fptr = fopen("num_devices.txt","r"); 
  int devicecount;
   if(fptr == NULL){ 
     cudaGetDeviceCount(&devicecount); 
     } 
   else{ 
     fscanf(fptr," %d ",&devicecount); 
     fclose(fptr); 
  }
  int* h_vertex_partition;
  int *h_edges;//data
  int *h_weight;
  int *h_offset;//meta
  int* h_src;
  int *h_rev_meta;
  int h_vertex_per_device;

  h_edges = (int *)malloc( (E)*sizeof(int));
  h_weight = (int *)malloc( (E)*sizeof(int));
  h_offset = (int *)malloc( (V+1)*sizeof(int));
  h_src = (int *)malloc( (E)*sizeof(int));
  h_vertex_partition = (int*)malloc((devicecount+1)*sizeof(int));
  h_rev_meta = (int *)malloc( (V+1)*sizeof(int));
  h_vertex_per_device = V/devicecount;

  for(int i=0; i<= V; i++) {
    h_offset[i] = g.indexofNodes[i];
    h_rev_meta[i] = g.rev_indexofNodes[i];
  }

  int index = 0;
  h_vertex_partition[0]=0;
  h_vertex_partition[devicecount]=V+1;
  for(int i=1;i<devicecount;i++){
    if(i<=(V%devicecount)){
       index+=(h_vertex_per_device+1);
    }
    else{
       index+=h_vertex_per_device;
    }
    h_vertex_partition[i]=index;
  }
  for(int i=0; i< E; i++){
    h_edges[i]= g.edgeList[i];
    h_src[i]=g.srcList[i];
    h_weight[i] = edgeLen[i];
  }


  int** d_offset;
  int** d_edges;
  int** d_weight;
  int** d_src;
  int** d_rev_meta;
  d_offset = (int**) malloc(devicecount*sizeof(int*));
  d_edges = (int**) malloc(devicecount*sizeof(int*));
  d_weight = (int**) malloc(devicecount*sizeof(int*));
  d_src = (int**) malloc(devicecount*sizeof(int*));
  d_rev_meta = (int**) malloc(devicecount*sizeof(int*));

  int perdevicevertices;
  int lastleftvertices;
  perdevicevertices = V / devicecount ;
  lastleftvertices = V % devicecount;
  for(int i=0;i<devicecount;i++)	
  {
    cudaSetDevice(i);
    cudaMalloc(&d_offset[i], (V+1)*sizeof(int) );
    cudaMalloc(&d_edges[i], (E)*sizeof(int) );
    cudaMalloc(&d_weight[i], (E)*sizeof(int) );
    cudaMalloc(&d_src[i], (E)*sizeof(int) );
    cudaMalloc(&d_rev_meta[i], (V+1)*sizeof(int) );
  }
  for(int i=0;i<devicecount;i++)	
  {
    cudaSetDevice(i);
    cudaMemcpyAsync(d_offset[i], h_offset, (V+1)*sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpyAsync(d_edges[i], h_edges, (E)*sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpyAsync(d_weight[i], h_weight, (E)*sizeof(int),cudaMemcpyHostToDevice );
    cudaMemcpyAsync(d_src[i], h_src, (E)*sizeof(int),cudaMemcpyHostToDevice );
    cudaMemcpyAsync(d_rev_meta[i], h_rev_meta, (V+1)*sizeof(int),cudaMemcpyHostToDevice );
  }
  for(int i=0;i<devicecount;i++)	
  {
    cudaSetDevice(i);
    cudaDeviceSynchronize();
  }

  const unsigned threadsPerBlock = 1024;
  unsigned numThreads   = (V < threadsPerBlock)? V: 1024;
  unsigned numBlocks    = (V+threadsPerBlock-1)/threadsPerBlock;


  // TIMER START
  cudaEvent_t start, stop;
  cudaEventCreate(&start);
  cudaEventCreate(&stop);
  float milliseconds = 0;
  cudaEventRecord(start,0);


  //DECLARE DEVICE AND HOST vars in params
  float** d_beta;
  d_beta = (float**)malloc(sizeof(float*)*devicecount);
  for (int i = 0; i < devicecount; i++) {
    cudaSetDevice(i);
    cudaMalloc(&d_beta[i], sizeof(float));
    initKernel<float> <<<1,1>>>(1,d_beta[i],beta);
  }

  float** h_beta = (float**)malloc(sizeof(float*)*(devicecount+1));
  for(int i=0;i<=devicecount;i++){
    h_beta[i] = (float*)malloc(sizeof(float));
  }
  float** d_delta;
  d_delta = (float**)malloc(sizeof(float*)*devicecount);
  for (int i = 0; i < devicecount; i++) {
    cudaSetDevice(i);
    cudaMalloc(&d_delta[i], sizeof(float));
    initKernel<float> <<<1,1>>>(1,d_delta[i],delta);
  }

  float** h_delta = (float**)malloc(sizeof(float*)*(devicecount+1));
  for(int i=0;i<=devicecount;i++){
    h_delta[i] = (float*)malloc(sizeof(float));
  }
  int** d_maxIter;
  d_maxIter = (int**)malloc(sizeof(int*)*devicecount);
  for (int i = 0; i < devicecount; i++) {
    cudaSetDevice(i);
    cudaMalloc(&d_maxIter[i], sizeof(int));
    initKernel<int> <<<1,1>>>(1,d_maxIter[i],maxIter);
  }

  int** h_maxIter = (int**)malloc(sizeof(int*)*(devicecount+1));
  for(int i=0;i<=devicecount;i++){
    h_maxIter[i] = (int*)malloc(sizeof(int));
  }
  float** h_pageRank;
  h_pageRank = (float**)malloc(sizeof(float*)*(devicecount+1));
  for(int i=0;i<=devicecount;i++){
    h_pageRank[i] = (float*)malloc(sizeof(float)*(V+1));
  }
  float** d_pageRank;
  d_pageRank = (float**)malloc(sizeof(float*)*devicecount);
  for (int i = 0; i < devicecount; i++) {
    cudaSetDevice(i);
    cudaMalloc(&d_pageRank[i], sizeof(float)*(V+1));
  }


  //BEGIN DSL PARSING 
  float num_nodes = (float)g.num_nodes(); // asst in .cu 
  float** h_num_nodes;
  h_num_nodes = (float**)malloc(sizeof(float*)*(devicecount+1));
  for(int i=0;i<=devicecount;i+=1){
    h_num_nodes[i] = (float*)malloc(sizeof(float));
  }

  float** d_num_nodes;
  d_num_nodes = (float**)malloc(sizeof(float*)*devicecount);
  for(int i = 0 ; i < devicecount ; i++){
    cudaSetDevice(i);
    cudaMalloc(&d_num_nodes[i],sizeof(float));
    initKernel<float> <<<1,1>>>(1,d_num_nodes[i],0);
  }


  float** h_pageRank_nxt;
  h_pageRank_nxt = (float**)malloc(sizeof(float*)*(devicecount+1));
  for(int i=0;i<=devicecount;i++){
    h_pageRank_nxt[i]=(float*)malloc(sizeof(float)*(V+1));
  }
  float** d_pageRank_nxt;
  d_pageRank_nxt = (float**)malloc(sizeof(float*)*devicecount);
  for (int i = 0; i < devicecount; i++) {
    cudaSetDevice(i);
    cudaMalloc(&d_pageRank_nxt[i], sizeof(float)*(V+1));
  }

  for(int i=0;i<devicecount;i++)
  {
    cudaSetDevice(i);
    initKernel<float> <<<numBlocks,threadsPerBlock>>>(V,d_pageRank[i],(float)1 / num_nodes);
  }
  int iterCount = 0; // asst in .cu 
  int** h_iterCount;
  h_iterCount = (int**)malloc(sizeof(int*)*(devicecount+1));
  for(int i=0;i<=devicecount;i+=1){
    h_iterCount[i] = (int*)malloc(sizeof(int));
  }

  int** d_iterCount;
  d_iterCount = (int**)malloc(sizeof(int*)*devicecount);
  for(int i = 0 ; i < devicecount ; i++){
    cudaSetDevice(i);
    cudaMalloc(&d_iterCount[i],sizeof(int));
    initKernel<int> <<<1,1>>>(1,d_iterCount[i],0);
  }


  float diff; // asst in .cu 
  float** h_diff;
  h_diff = (float**)malloc(sizeof(float*)*(devicecount+1));
  for(int i=0;i<=devicecount;i+=1){
    h_diff[i] = (float*)malloc(sizeof(float));
  }

  float** d_diff;
  d_diff = (float**)malloc(sizeof(float*)*devicecount);
  for(int i = 0 ; i < devicecount ; i++){
    cudaSetDevice(i);
    cudaMalloc(&d_diff[i],sizeof(float));
    initKernel<float> <<<1,1>>>(1,d_diff[i],0);
  }


  do{
    diff = 0.000000;
    for(int i=0;i<devicecount;i++){
      cudaSetDevice(i);
      initKernel<float> <<<1,1>>>(1,d_diff[i],(float)0.000000);
    }
    for(int i=0;i<devicecount;i++)
    {
      cudaSetDevice(i);
      Compute_PR_kernel1<<<numBlocks, threadsPerBlock>>>(h_vertex_partition[i],h_vertex_partition[i+1],V,E,d_offset[i],d_edges[i],d_weight[i],d_src[i],d_rev_meta[i],d_delta[i],d_diff[i],d_num_nodes[i],d_pageRank[i],d_pageRank_nxt[i]);
    }

    for(int i=0;i<devicecount;i++)
    {
      cudaSetDevice(i);
      cudaDeviceSynchronize();
    }
    for(int i=0;i<devicecount;i++){
      cudaSetDevice(i);
      cudaMemcpyAsync(h_delta[i],d_delta[i],sizeof(float),cudaMemcpyDeviceToHost);
    }
    for(int i=0;i<devicecount;i++){
      cudaSetDevice(i);
      cudaMemcpyAsync(h_diff[i],d_diff[i],sizeof(float),cudaMemcpyDeviceToHost);
    }
    for(int i=0;i<devicecount;i++){
      cudaSetDevice(i);
      cudaMemcpyAsync(h_num_nodes[i],d_num_nodes[i],sizeof(float),cudaMemcpyDeviceToHost);
    }
    for(int i=0;i<devicecount;i++){
      cudaSetDevice(i);
      cudaMemcpyAsync(h_pageRank[i],d_pageRank[i],sizeof(float)*(V+1),cudaMemcpyDeviceToHost);
    }
    for(int i=0;i<devicecount;i++){
      cudaSetDevice(i);
      cudaMemcpyAsync(h_pageRank_nxt[i],d_pageRank_nxt[i],sizeof(float)*(V+1),cudaMemcpyDeviceToHost);
    }
    for(int i=0;i<devicecount;i++){
      cudaSetDevice(i);
      cudaDeviceSynchronize();
    }


    for(int i=0;i<devicecount;i++){
      diff += h_diff[i][0];
    } //end of for
    for(int i=0;i<devicecount;i++){
      diff += h_diff[i][0];
    } //end of for
    float* h_temp=(float*)malloc(sizeof(float)*(V+1));
    for(int i=0;i<devicecount;i++){
      cudaSetDevice(i);
      cudaMemcpy(h_temp+h_vertex_partition[i],d_pageRank_nxt[i]+h_vertex_partition[i],sizeof(float)*(h_vertex_partition[i+1]-h_vertex_partition[i]),cudaMemcpyDeviceToHost);
    }
    for(int i=0;i<devicecount;i++){
      cudaSetDevice(i);
      cudaDeviceSynchronize();
    }
    for(int i=0;i<devicecount;i++){
      cudaSetDevice(i);
      cudaMemcpy(d_pageRank[i],h_temp,sizeof(float)*(V),cudaMemcpyHostToDevice);
    }
    iterCount++;
  }while((diff > beta) && (iterCount < maxIter));
  //TIMER STOP
  cudaEventRecord(stop,0);
  cudaEventSynchronize(stop);
  cudaEventElapsedTime(&milliseconds, start, stop);
  printf("GPU Time: %.6f ms\n", milliseconds);

  cudaMemcpy(pageRank, d_pageRank[0], sizeof(float)*(V), cudaMemcpyDeviceToHost  );
} //end FUN
int main(int argc, char* argv[]){
   
   char* filename = argv[1];
   graph g(filename);
   g.parseGraph();
 float beta = 0.001; 
 float delta = 0.85; 
 int maxIter = 100; 
 int n=g.num_nodes(); 
  float*  pageRank=(float*)malloc((g.num_nodes()+1)*sizeof(float));

  for(int i=0;i<=n;i++)
  {
    pageRank[i]=1/n;
  }
  Compute_PR(g,beta,delta,maxIter,pageRank);
 
  for(int i=0;i<=n;i++)
  {
     printf("%0.10f\n",pageRank[i]);  
  }

  return 0;
}

// int main(int argc, char* argv[]){
   
//    char* filename = argv[1];
//    graph g(filename);
//    g.parseGraph();
//  float beta = 0.001; 
//  float delta = 0.85; 
//  int maxIter = 100; 
//  int n=g.num_nodes(); 
//   float*  pageRank=(float*)malloc((g.num_nodes()+1)*sizeof(float));
//    int res[n];
//    map<float,int>mp;
//   for(int i=0;i<=n;i++)
//   {
//     pageRank[i]=1/n;
//   }
//   Compute_PR(g,beta,delta,maxIter,pageRank);
//  for(int i=0;i<=n;i++)
//   {
//    mp[pageRank[i]]=i;
//   }
//   int j=1;
//   for(auto it:mp)
//   {
//     //ith element it->first
//     res[it.second]=j;j++;
//   }
//   for(int i=0;i<=n;i++)
//   {
//      printf("%d\n",res[i]);  
//   }

//   return 0;
// }