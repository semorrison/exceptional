--multiplicities of representations
--order is 1,X1,,X2,Y2(*),A,C(*),X3,Y3,D(*),E,F(*),G(*),H(*),I(*),J,X4,Y4(*)

mult0 = [1]
mult1 = [0,1]
mult2 = [1,1,1,1,1]
mult3 = [1,5,4,3,3,3,2,2,1,1,1]
mult4 = [5,16,23,18,18,21,16,16,12,6,6,6,6,8,6,6,3,3,2,2,3,3,3,1,1,1]

dotprod a b = sum (zipWith (*) a b)

