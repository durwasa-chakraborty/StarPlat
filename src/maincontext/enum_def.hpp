/*enum for various graph characteristics*/
#ifndef ENUMDEF_H
#define ENUMDEF_H

enum TYPE
{
 TYPE_LONG,
 TYPE_INT,
 TYPE_BOOL,
 TYPE_FLOAT,
 TYPE_DOUBLE,
 TYPE_GRAPH,
 TYPE_DIRGRAPH,
 TYPE_LIST,
 TYPE_SETN,
 TYPE_SETE,
 TYPE_NODE,
 TYPE_EDGE,
 TYPE_PROPNODE,
 TYPE_PROPEDGE,
 TYPE_NONE,
 TYPE_UPDATES,
 TYPE_VECTOR,

};

inline bool check_isNodeEdgeType(int typeId)
{
  return ((typeId==TYPE_NODE)||(typeId==TYPE_EDGE));
}
inline bool check_isPropType(int typeId)
{
  return ((typeId==TYPE_PROPNODE)||(typeId==TYPE_PROPEDGE));
}
inline bool check_isCollectionType(int typeId)
{
  return ((typeId == TYPE_LIST)||(typeId==TYPE_SETE)||(typeId==TYPE_SETN)||(typeId == TYPE_UPDATES)||(typeId == TYPE_VECTOR));
}

inline bool check_isGraphType(int typeId)
{
  return ((typeId==TYPE_GRAPH)||(typeId==TYPE_DIRGRAPH));
}
inline bool check_isPrimitiveType(int typeId)
  {
    return ((typeId==TYPE_BOOL)||(typeId==TYPE_DOUBLE)||(typeId==TYPE_FLOAT)||(typeId==TYPE_LONG)||(typeId==TYPE_INT));
  }

 inline bool check_isPropNodeType(int typeId)
 {
   return typeId==TYPE_PROPNODE;
 }

 inline bool check_isPropEdgeType(int typeId)
 {
   return typeId==TYPE_PROPEDGE;
 }

inline bool check_isVectorCollectionType(int typeId)
{
  return typeId==TYPE_VECTOR;
}

inline bool check_isListCollectionType(int typeId)
{
  return typeId==TYPE_LIST;
}
inline bool check_isSetCollectionType(int typeId)
{
  return ((typeId==TYPE_SETN)||(typeId==TYPE_SETE));
}
inline bool check_isNodeType(int typeId)
{
  return typeId==TYPE_NODE;
}
inline bool check_isEdgeType(int typeId)
{
  return typeId==TYPE_EDGE;
}

enum REDUCE
{
    REDUCE_SUM,
    REDUCE_COUNT,
    REDUCE_PRODUCT,
    REDUCE_MAX,
    REDUCE_MIN,
   

};

enum OPERATOR
{
 OPERATOR_ADD,
 OPERATOR_SUB,
 OPERATOR_MUL,
 OPERATOR_DIV,
 OPERATOR_MOD,
 OPERATOR_OR,
 OPERATOR_AND,
 OPERATOR_LT,
 OPERATOR_GT,
 OPERATOR_LE,
 OPERATOR_GE,
 OPERATOR_EQ,
 OPERATOR_NE,
 OPERATOR_NOT,
 OPERATOR_INC,
 OPERATOR_DEC,
 OPERATOR_ADDASSIGN,
 OPERATOR_MULASSIGN,
 OPERATOR_ORASSIGN,
 OPERATOR_ANDASSIGN,
 OPERATOR_SUBASSIGN,

};

enum FUNCTYPE
{
  GEN_FUNC,
  STATIC_FUNC,
  INCREMENTAL_FUNC,
  DECREMENTAL_FUNC,
  DYNAMIC_FUNC,
  
};

enum NODETYPE{
  NODE_ID,               //0
  NODE_PROPACCESS,       //1
  NODE_FUNC,             //2 
  NODE_TYPE,             //3
  NODE_FORMALPARAM,      //4
  NODE_STATEMENT,        //5
  NODE_BLOCKSTMT,        //6
  NODE_DECL,             //7
  NODE_ASSIGN,           //8
  NODE_WHILESTMT,        //9
  NODE_DOWHILESTMT,      //10
  NODE_FIXEDPTSTMT,      //11
  NODE_IFSTMT,           //12
  NODE_ITRBFS,           //13
  NODE_ITRRBFS,          //14
  NODE_EXPR,             //15
  NODE_PROCCALLEXPR,     //16
  NODE_PROCCALLSTMT,     //17
  NODE_FORALLSTMT,       //18
  NODE_REDUCTIONCALL,    //19
  NODE_REDUCTIONCALLSTMT, //20
  NODE_UNARYSTMT,        //21
  NODE_RETURN,           //22
  NODE_BATCHBLOCKSTMT,   //23
  NODE_ONADDBLOCK,       //24
  NODE_ONDELETEBLOCK,    //25
  NODE_TRANSFERSTMT,     //26
};


enum EXPR
{
   EXPR_RELATIONAL,
   EXPR_LOGICAL,
   EXPR_ARITHMETIC,
   EXPR_UNARY,
   EXPR_BOOLCONSTANT,
   EXPR_INTCONSTANT,
   EXPR_LONGCONSTANT,
   EXPR_DOUBLECONSTANT,
   EXPR_FLOATCONSTANT,
   EXPR_ID,
   EXPR_PROPID,
   EXPR_INFINITY,
   EXPR_PROCCALL,
   EXPR_DEPENDENT,
};

static const char *currentBatch = "currentBatch";
static const char *attachNodeCall = "attachNodeProperty";
static const char *attachEdgeCall = "attachEdgeProperty" ;
static const char* nbrCall = "neighbors" ;
static const char* edgeCall   = "get_edge" ;
static const char* countOutNbrCall = "count_outNbrs";
static const char* isAnEdgeCall = "is_an_edge"; 
static const char* nodesToCall = "nodes_to";
static const char* nodesCall = "nodes";

// functions for set
static const char *elements = "elements";
static const char *contains = "contains";
static const char *addNode = "addNode";
static const char *addSetN = "addSetN";
static const char *discard = "discard";
static const char *totalElements = "totalElements";
static const char *isEmpty = "isEmpty";

#endif

