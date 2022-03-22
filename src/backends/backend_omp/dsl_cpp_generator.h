#include <cstdio>
#include "../../ast/ASTNodeTypes.hpp"
#include "../../parser/includeHeader.hpp"

#ifndef DSL_CPP_GENERATOR
#define DSL_CPP_GENERATOR

#include "../dslCodePad.h"

class dsl_cpp_generator
{
  protected:

  dslCodePad header;
  dslCodePad main;
  FILE *headerFile;
  FILE *bodyFile;
  char* fileName;
  int genFuncCount;
  int staticFuncCount;
  int inFuncCount;
  int decFuncCount;
  int curFuncType;
  vector<pair<Identifier*,proc_callExpr*>> forallStack;
 
  public:
  dsl_cpp_generator()
  {
    headerFile=NULL;
    bodyFile=NULL;
    fileName=new char[1024];
    genFuncCount = 0;
    staticFuncCount = 0;
    inFuncCount = 0;
    decFuncCount = 0;
 }

  void setFileName(char* f);
  bool generate();
  void generation_begin();
  void generation_end();
  bool openFileforOutput();
  void closeOutputFile();
  const char* convertToCppType(Type* type);
  void castIfRequired(Type* type,Identifier* methodID,dslCodePad& main);
  const char* getOperatorString(int operatorId);
  void generateFunc(ASTNode* proc);
  void generateFuncHeader(Function* proc,bool isMainFile);
  void generateProcCall(proc_callStmt* procCall);
  void generateVariableDecl(declaration* decl);
  void generateStatement(statement* stmt);
  void generateAssignmentStmt(assignment* assignStmt);
  void generateWhileStmt(whileStmt* whilestmt);
  virtual void generateForAll(forallStmt* forAll);
  void generateFixedPoint(fixedPointStmt* fixedPoint);
  void generateIfStmt(ifStmt* ifstmt);
  void generateDoWhileStmt(dowhileStmt* doWhile);
  void generateBFS();
  void generateBlock(blockStatement* blockStmt, bool includeBrace=true);
  void generateReductionStmt(reductionCallStmt* reductnStmt);
  void generateReductionCallStmt(reductionCallStmt* stmt);
  void generateReductionOpStmt(reductionCallStmt* stmt);
  void generateBFSAbstraction(iterateBFS* bfsAbstraction);
  void generateExpr(Expression* expr);
  void generate_exprRelational(Expression* expr);
  void generate_exprInfinity(Expression* expr);
  void generate_exprLiteral(Expression* expr);
  void generate_exprIdentifier(Identifier* id);
  virtual void generate_exprPropId(PropAccess* propId) ;
  void generate_exprPropIdReceive(PropAccess* propId);
  void generate_exprProcCall(Expression* expr);
  void generate_exprArL(Expression* expr);
  void generate_exprUnary(Expression* expr);
  void generateForAll_header(forallStmt* forAll);
  void getEdgeTranslation(Expression* expr); //translation of edge assignment.
  virtual void generateForAllSignature(forallStmt* forAll);
  void generatefixedpt_filter(Expression* filterExpr);
  //void includeIfToBlock(forallStmt* forAll);
  bool neighbourIteration(char* methodId);
  bool allGraphIteration(char* methodId);
  bool elementsIteration(char* extractId);
  void generateBarrier();
  
  blockStatement* includeIfToBlock(forallStmt* forAll);

  void generateId();
  void generateOid();
  void addIncludeToFile(char* includeName,dslCodePad& file,bool isCPPLib);
  void generatePropertyDefination(Type* type,char* Id);
  void findTargetGraph(vector<Identifier*> graphTypes,Type* type);
  void incFuncCount(int funcType);
  int curFuncCount();
  void getDefaultValueforTypes(int type);



};

 static const char* INTALLOCATION = "new int";
 static const char* BOOLALLOCATION = "new bool";
 static const char* FLOATALLOCATION = "new float";
 static const char* DOUBLEALLOCATION = "new double";
#endif
