(* ::Package:: *)

(************************************************************************)
(* This file was generated automatically by the Mathematica front end.  *)
(* It contains Initialization cells from a Notebook file, which         *)
(* typically will have the same name as this file except ending in      *)
(* ".nb" instead of ".m".                                               *)
(*                                                                      *)
(* This file is intended to be loaded into the Mathematica kernel using *)
(* the package loading commands Get or Needs.  Doing so is equivalent   *)
(* to using the Evaluate Initialization Cells menu command in the front *)
(* end.                                                                 *)
(*                                                                      *)
(* DO NOT EDIT THIS FILE.  This entire file is regenerated              *)
(* automatically each time the parent Notebook file is saved in the     *)
(* Mathematica front end.  Any changes you make to this file will be    *)
(* overwritten.                                                         *)
(************************************************************************)



SetOptions[InputNotebook[],AutoGeneratedPackage->Automatic]


BeginPackage["GuessingPolynomials`"];


FindPolynomial;FindMultivariablePolynomial;FindVerifiedMultivariablePolynomial;SchwartzZippelDeterminant;SchwartzZippelNullSpace;ParallelInverse;ParallelInverseProduct;ParallelNullSpace


Begin["`Private`"];


FindPolynomialStep=1000;


FindPolynomial[v_][f_]:=Module[{n=0,p,result={$Failed},primes={},values={},k,attempts},
p[n_]:=p[n]=Prime[1+n FindPolynomialStep]+Mod[n,2];
While[!FreeQ[{result},$Failed]\[Or](result/.v->p[n+1])=!=f[p[n+1]],
n++;
AppendTo[primes,p[n]];
AppendTo[values,f[p[n]]];
attempts={};
k=0;
While[Length[attempts]<Length[values]\[And]Length[Cases[attempts,a_/;FreeQ[a,$Failed]]]==0,
AppendTo[attempts,FindPolynomial[v,Drop[primes,k]][Drop[values,k]]];
k++];
result=If[k==Length[values],
attempts[[1]],
attempts[[-1]]
];
];
result
]


FindPolynomial[v_,primes_][values:{___Integer}]:=Module[{e},
(*Print["FindPolynomial[",v,",",primes,"][",values,"]"];*)
If[Max[Abs[values]]<=10^50,
e=GCD@@Flatten[(FactorInteger/@values)[[All,All,2]]];
FindNonPowerPolynomial[v,primes][Surd[values,e]]^e,
FindNonPowerPolynomial[v,primes][values]
]
]
FindPolynomial[v_,primes_][values:{___Rational}]/;MatchQ[Union[Numerator/@values],{1}|{-1}]:=FindPolynomial[v,primes][values^-1]^-1
FindPolynomial[v_,primes_][values:{___Rational}]:=FindPolynomial[v,primes][Numerator[values]]/FindPolynomial[v,primes][Denominator[values]]
FindPolynomial[v_,primes_][values_]:=(Message[FindPolynomial::badvalues];Abort[])


FindNonPowerPolynomial[v_,primes_][{0...}]:=0
FindNonPowerPolynomial[v_,primes_][values:{___Integer}]:=Module[{residues,crt,next},
(*Print[values];*) 
residues=Mod[#[[1]],#[[2]],-#[[2]]/2]&/@Transpose[{values,primes}];
crt=ChineseRemainder[residues,primes];
If[MatchQ[crt,_ChineseRemainder],
$Failed,
crt=Mod[crt,Times@@primes,-(Times@@primes)/2];
(*Print[residues];
Print[crt];*) 
If[Abs[crt/(Times@@primes)]<1/10,
next=FindNonPowerPolynomial[v,primes][(values-crt)/primes];
If[next===$Failed,
$Failed,
crt+v next
],
$Failed
]
]
]
(*FindNonPowerPolynomial[v_,primes_][values:{___Integer}]:=InterpolatingPolynomial[Transpose[{primes,values}],v]*)


FindMultivariablePolynomial[{v_}][f_]:=(*FindPolynomial[v][f]*)f[v]
FindMultivariablePolynomial[variables_][f_]:=Module[{v=First[variables],ev,p,n=0,result=$Failed,primes={},values={},k,attempts},
Print["FindMultivariablePolynomial[",variables,"][...]"];
p[n_]:=p[n]=Prime[1+n  FindPolynomialStep]+Mod[n,2];
ev[n_]:=ev[n]=Factor[FindMultivariablePolynomial[Rest[variables]][f[p[n],##]&]];
While[!FreeQ[{result},$Failed]\[Or]Together[(result/.v->p[n+1])-ev[n+1]]=!=0,
Print[result];
n++;
AppendTo[primes,p[n]];
AppendTo[values,ev[n]];
(*Print[n];
Print[primes];
Print[values];*)

attempts={};
k=0;
While[Length[attempts]<Length[values]\[And]Length[Cases[attempts,a_/;FreeQ[a,$Failed]]]==0,
AppendTo[attempts,FindMultivariablePolynomial[v,Drop[primes,k]][Drop[values,k]]];
k++];
result=If[k==Length[values],
attempts[[1]],
attempts[[-1]]
];
];
result
]


FindMultivariablePolynomial[v_,{}][{}]:=$Failed
FindMultivariablePolynomial[v_,primes_][values:{___Integer}]:=FindPolynomial[v,primes][values]
FindMultivariablePolynomial[v_,primes_][values:{___Times}]:=Module[{factors},
If[Length[Union[Length/@values]]==1,
factors=Table[FindMultivariablePolynomial[v,primes][values[[All,i]]],{i,1,Length[values[[1]]]}];
If[FreeQ[factors,$Failed],Times@@factors,FindMultivariablePolynomialDirect[v,primes][Numerator/@values]/FindMultivariablePolynomialDirect[v,primes][Denominator/@values]],
FindMultivariablePolynomial[v,Rest[primes]][Rest[values]]
]
]
FindMultivariablePolynomial[v_,primes_][values:{___Power}]:=Module[{},
If[Length[Union[values[[All,2]]]]==1,
FindMultivariablePolynomial[v,primes][values[[All,1]]]^values[[1,2]],
FindMultivariablePolynomial[v,Rest[primes]][Rest[values]]
]
]
FindMultivariablePolynomial[v_,primes_][values_]:=FindMultivariablePolynomialDirect[v,primes][values]
FindMultivariablePolynomialDirect[v_,primes_][values_]:=Module[{variables,exponents,coefficients},
variables=Variables[values];
(*Print["primes: ",primes];
Print["values: ",values];
Print["v: ",v];
Print["variables: ",variables];
*)coefficients=CoefficientRules[values,variables];
exponents=Union[Flatten[coefficients[[All,All,1]],1]];
(*Print["coefficients: ",coefficients];
Print["exponents: ",exponents];*)
Factor[Sum[FindPolynomial[v,primes][(e/.coefficients)](Times@@(variables^e)),{e,exponents}]]
]


FindVerifiedMultivariablePolynomial[degreeBound0_,probability_:10^-50][variables_][f_]:=
Module[{guess=FindMultivariablePolynomial[variables][f],degreeBound,probabilityBound=1,FindPolynomialStep0=FindPolynomialStep,S,bestTiming=\[Infinity],timing,result,p},
degreeBound=degreeBound0+Total[Exponent[Numerator[guess],Variables[guess]]]+Total[Exponent[Denominator[guess],Variables[guess]]];
S=2degreeBound;
While[probabilityBound>probability,
(*Print[{N[probabilityBound],S}];*)
p=Table[RandomInteger[{1,S}],{Length[variables]}];
{timing,result}=AbsoluteTiming[(guess/.(Thread[variables->p]))-(f@@p)===0];
timing=timing/Log[S];
If[result,
probabilityBound=probabilityBound degreeBound / S;
(* update S, based on timing *)
If[timing<bestTiming,
bestTiming=timing;
S*=2
],
FindPolynomialStep*=2;
guess=FindMultivariablePolynomial[variables][f];
degreeBound=degreeBound0+Total[Exponent[Numerator[guess],Variables[guess]]]+Total[Exponent[Denominator[guess],Variables[guess]]];
S=2degreeBound;
probabilityBound=1
];
];
FindPolynomialStep=FindPolynomialStep0;
guess
]


totalDegree[f_]:=Module[{t=Together[f],v=Variables[f]},(Total[Exponent[Numerator[t],v]])+(Total[Exponent[Denominator[t],v]])
]


SchwartzZippelDeterminant[matrix_,probabilityBound_:10^-50]:=Module[{variables,degreeBound},
variables=Reverse[SortBy[Variables[matrix],Max[Exponent[matrix,#]]&]];
degreeBound=Total[Max/@Map[totalDegree,matrix,{2}]];
FindVerifiedMultivariablePolynomial[degreeBound,probabilityBound][variables][(Print["evaluating at ",{##}];Det[matrix/.Thread[variables->{##}]])&]
]



ParallelInverse[matrix_]:=Module[{variables,degreeBound,det,inverse},
variables=Reverse[SortBy[Variables[matrix],Max[Exponent[matrix,#]]&]];
inverse[v___]:=inverse[v]=(Print[DateString[]<> " calculating inverse at ",{v}];
onDiskParallelInverse[matrix/.Thread[variables->{v}],"inverse-rows"]);
Table[FindMultivariablePolynomial[variables][inverse[##][[i,j]]&],{i,1,Length[matrix]},{j,1,Length[matrix]}]
]


ParallelInverseProduct[matrix1_,matrix2_]:=Module[{variables,degreeBound,det,inverse,evaluation,result,product,productpart},
variables=Reverse[SortBy[Variables[matrix2],Max[Exponent[matrix2,#]]&]];
inverse[v___]:=inverse[v]=(Print[DateString[]<> " calculating inverse at ",{v}];
onDiskParallelInverse[matrix2/.Thread[variables->{v}],"inverse-rows"]);
evaluation[v___]:=Together[matrix1/.Thread[variables->{v}]];
product[v___]:=product[v]=evaluation[v].inverse[v];
productpart[i_,j_][v___]:=productpart[i,j][v]=Together[product[v][[i,j]]];
Do[product[Prime[1+1000n]+Mod[n,2],variables[[2]]],{n,1,5}];
Table[Print[DateString[]<> " computing matrix1.Inverse[matrix2][[",i,",",j,"]]"];result=TimeConstrained[FindMultivariablePolynomial[variables][((productpart[i,j][##]))&],30];
Print["obtained ",result];result,{i,1,Length[matrix1]},{j,1,Length[matrix2]}]
]


echo[x_]:=(Print[x];x)


SchwartzZippelNullSpace[matrix_,probabilityBound_:10^-50]:=Module[{e,m,v},
e=SchwartzZippelDeterminant[Drop[matrix,{},{-1}],probabilityBound];
m=ReplacePart[matrix,1->Factor[matrix[[1]]/e]];
v=Table[echo[(-1)^k SchwartzZippelDeterminant[Drop[m,{},{k}],probabilityBound]],{k,1,Length[matrix[[1]]]}];
Factor[v/v[[-1]]]
]


onDiskParallelNullSpace[matrix_,f_]:=Module[{almost,result,hash,cacheFile,s},
hash=IntegerString[Hash[matrix,"SHA1"],16,16];
cacheFile=FileNameJoin[{NotebookDirectory[],"matrices","nullspace-"<>hash<>".m"}];
If[FileExistsQ[cacheFile],
Get[cacheFile],
s=Reverse[Range[Length[matrix]]];
almost=Reverse[onDiskParallelRowReduce[matrix,f]][[All,s]];
almost=Reverse[onDiskParallelRowReduce[almost,f]][[All,s]];
result=NullSpace[almost];
If[Length[result]==1,
result=result[[1]],
Print["NullSpace not one-dimensional"];Abort[]];
If[Together[matrix.result]===Table[0,{Length[matrix]}],
Put[result,cacheFile];
result,
Print[result];
Abort[]
]
]
]


ParallelNullSpace[matrix_]:=Module[{variables,degreeBound,nullspace,evaluation,result,resultpart},
variables=Reverse[SortBy[Variables[matrix],Max[Exponent[matrix,#]]&]];
nullspace[v___]:=nullspace[v]=(Print[DateString[]<> " calculating nullspace at ",{v}];
onDiskParallelNullSpace[matrix/.Thread[variables->{v}],"nullspace"]);
resultpart[i_][v___]:=resultpart[i][v]=Together[nullspace[v][[i]]];
Do[nullspace[Prime[1+1000n]+Mod[n,2],variables[[2]]],{n,1,5}];
Table[Print[DateString[]<> " computing NullSpace[matrix][[",i,"]]"];result=TimeConstrained[FindMultivariablePolynomial[variables][((resultpart[i][##]))&],30];
Print["obtained ",result];result,{i,1,Length[matrix]}]
]


inMemoryParallelRowReduce[matrix_]:=Module[{m,load,save},
load[j_]:=m[[j]];
save[j_,row_]:=m[[j]]=row;
m=matrix;
SetSharedVariable[m];
DistributeDefinitions[load,save];
parallelRowReduce[Length[matrix],1,load,save]
]


onDiskParallelRowReduce[matrix_,namer_]:=Module[{load,save},
load[j_]:=Get[namer[j]];
save[j_,row_]:=Put[row,namer[j]];
Do[save[j,matrix[[j]]],{j,1,Length[matrix]}];
DistributeDefinitions[load,save];
parallelRowReduce[Length[matrix],1,load,save]
]
onDiskParallelRowReduce[matrix_,tag_String]:=
With[{nbd=NotebookDirectory[]},onDiskParallelRowReduce[matrix,FileNameJoin[{nbd,"matrices",tag<>"-"<>ToString[#]<>".m"}]&]
]


onDiskParallelInverse[matrix_,f_]:=Module[{augmented,s,almost,result,hash,cacheFile},
hash=IntegerString[Hash[matrix,"SHA1"],16,16];
cacheFile=FileNameJoin[{NotebookDirectory[],"matrices","inverse-"<>hash<>".m"}];
If[FileExistsQ[cacheFile],
Get[cacheFile],
augmented=ArrayFlatten[{{matrix,IdentityMatrix[Length[matrix]]}}];
s=Reverse[Range[Length[matrix]]]~Join~(Range[Length[matrix]]+Length[matrix]);
almost=Reverse[onDiskParallelRowReduce[augmented,f]][[All,s]];
almost=Reverse[onDiskParallelRowReduce[almost,f]][[All,s]];
result=Table[Together[almost[[k,Length[matrix]+1;;]]/almost[[k,k]]],{k,1,Length[matrix]}];
If[Together[result.matrix]===IdentityMatrix[Length[matrix]],
Put[result,cacheFile];
result,
Abort[]
]
]
]


parallelRowReduce[n_Integer,k_Integer,load_,save_]:=
Module[{row,pivots},
If[k>n,
Table[load[j],{j,1,n}],
Print[DateString[]," row reducing at row ",k];
row=load[k];
If[row[[k]]===0,
(* we need to pivot first *)
pivots=Cases[Range[k+1,n],j_/;load[j][[k]]=!=0,1,1];
If[Length[pivots]==0,
(* proceed, no need to pivot *)
parallelRowReduce[n,k+1,load,save],
save[k,load[pivots[[1]]]];
save[pivots[[1]],row];
parallelRowReduce[n,k,load,save]],
(* actually do the row reduction *)
ParallelDo[
Module[{r1,r2},
r1=load[k];
r2=load[j];
save[j,Together[r2-r2[[k]]/r1[[k]] r1]]
]
,{j,k+1,n}];
parallelRowReduce[n,k+1,load,save]
]
]
]


End[];


EndPackage[];


