##Continuous data
library(geiger)
library(pic)
tree.primates <- read.tree(text="((((Homo:0.21,Pongo:0.21):0.28,Macaca:0.49):0.13,Ateles:0.62):0.38,Galago:1.00);") #using examples from ape ?pic
X <- c(4.09434, 3.61092, 2.37024, 2.02815, -1.46968)
Y <- c(4.74493, 3.33220, 3.36730, 2.89037, 2.30259)
names(X) <- names(Y) <- c("Homo", "Pongo", "Macaca", "Ateles", "Galago")
pic.X <- pic(X, tree.primates)
pic.Y <- pic(Y, tree.primates)

##Discrete data
require("corHMM")
?corHMM
data(primates)
ls()
print(primates)
require(phytools)

#First, a review of discrete state models:
primates$trait[which(grepl("Hylobates",primates$trait[,1])),2]<-1

trait1<-primates$trait[,2]
names(trait1)<-primates$trait[,1]
plotSimmap(make.simmap(primates$tree, trait1), pts=FALSE, fsize=0.8)
rate.mat.er<-rate.mat.maker(rate.cat=1, hrm=FALSE, ntraits=1, nstates=2, model="ER")
print(rate.mat.er)

#What does this matrix mean?
### This is a rate matrix that gives you the rate/likelihood of going from one character state to another. In this matrix there is an equal rate of going from 1 to 0 or 0 to 1.

pp.er<-corHMM(primates$tree,primates$trait[,c(1,2)],rate.cat=1,rate.mat=rate.mat.er,node.states="marginal")
print(pp.er)


#What do these results mean?
### These results mean that even after estimating hidden rates underlying the evolution of these characters there is still an equal rate of going from 1 to 0 or 0 to 1.

rate.mat.ard<-rate.mat.maker(rate.cat=1, hrm=FALSE, ntraits=1, nstates=2, model="ARD")
print(rate.mat.ard)


#And these?
### These results indicate that after looking at these hidden rates it is twice as likely to go from 1 to 2 as it is to go from 2 to 1.

pp.ard<-corHMM(primates$tree,primates$trait[,c(1,2)],rate.cat=1,rate.mat=rate.mat.ard,node.states="marginal")
print(pp.ard)

#which model is better?
### Based on the AIC scores the pp.er model is slightly better. However, both models are within two AIC units of each other so either model is valid so long as you defend why you used the model you chose to use. 

rate.mat.er.4state<-rate.mat.maker(rate.cat=1, hrm=FALSE, ntraits=1, nstates=4, model="ER")
print(rate.mat.er.4state)
fourstate.trait<-rep(NA,Ntip(primates$tree))
for(i in sequence(Ntip(primates$tree))) {
  if(primates$trait[i,2]==0 && primates$trait[i,3]==0) {
    fourstate.trait[i]<-0
  }	
  if(primates$trait[i,2]==0 && primates$trait[i,3]==1) {
    fourstate.trait[i]<-1
  }	
  if(primates$trait[i,2]==1 && primates$trait[i,3]==0) {
    fourstate.trait[i]<-2
  }	
  if(primates$trait[i,2]==1 && primates$trait[i,3]==1) {
    fourstate.trait[i]<-3
  }	
}
fourstate.data<-data.frame(Genus_sp=primates$trait[,1], T1=fourstate.trait)

print(rayDISC(primates$tree, fourstate.data, ntraits=1, model="ER", node.states="marginal"))
print(rayDISC(primates$tree, fourstate.data, ntraits=1, rate.mat=rate.mat.er.4state, node.states="marginal", model="ARD"))
rate.mat.ard.4state<-rate.mat.maker(rate.cat=1, hrm=FALSE, ntraits=1, nstates=4, model="ARD")
print(rate.mat.ard.4state)

rate.mat.gtr.4state<-rate.mat.ard.4state
rate.mat.gtr.4state<-rate.par.eq(rate.mat.gtr.4state, c(1,4))
rate.mat.gtr.4state<-rate.par.eq(rate.mat.gtr.4state, c(2,6))
rate.mat.gtr.4state<-rate.par.eq(rate.mat.gtr.4state, c(3,8))
rate.mat.gtr.4state<-rate.par.eq(rate.mat.gtr.4state, c(4,6))
rate.mat.gtr.4state<-rate.par.eq(rate.mat.gtr.4state, c(5,7))
rate.mat.gtr.4state<-rate.par.eq(rate.mat.gtr.4state, c(6,7))
print(rate.mat.gtr.4state)

print(rayDISC(primates$tree, fourstate.data, ntraits=1, rate.mat= rate.mat.gtr.4state, node.states="marginal", model="ARD"))

#Pagel
print(rate.mat.maker(rate.cat=1, hrm=FALSE, ntraits=2, nstates=2, model="ARD"))
rate.mat.pag94<-rate.par.drop(rate.mat.ard.4state, drop.par=c(3,5,8,10))
print(rate.mat.pag94)

######### MODEL MAKING ###############
**Construct a model to test if state 1 can never be lost**
print(rayDISC(primates$tree, fourstate.data, ntraits=1, model="ER", node.states="marginal"))
print(rayDISC(primates$tree, fourstate.data, ntraits=1, rate.mat=rate.mat.er.4state, node.states="marginal", model="ARD"))
rate.matrix2.ard.4state<-rate.mat.maker(rate.cat=1, hrm=FALSE, ntraits=1, nstates=4, model="ARD")
print(rate.matrix2.ard.4state)
rate.matrix2drop<-rate.par.drop(rate.matrix2.ard.4state,drop.par=c(4,7,10))
print(rate.matrix2drop)
print(rayDISC(primates$tree, fourstate.data, ntraits=1, rate.mat= rate.matrix2drop, node.states="marginal", model="ARD"))
#This isn't good, our AIC score doubled. 


**Experiment with the effects of frequencies at the root.**
print(rayDISC(phy=primates$tree, data=fourstate.data, ntraits=1, rate.mat=rate.mat.er.4state, node.states="marginal",root.p="NULL", model="ARD"))
#AIC= 106.3497

print(rayDISC(phy=primates$tree, data=fourstate.data, ntraits=1, rate.mat=rate.mat.er.4state, node.states="marginal",root.p="maddfitz", model="ARD")) 
#AIC= 106.3497

print(rayDISC(phy=primates$tree, data=fourstate.data, ntraits=1, rate.mat=rate.mat.er.4state, node.states="marginal",root.p="yang", model="ARD"))  
#AIC= 107.9277


**Create and use a model to see if transitions from 00 go to 11 only via 01.**
rate.mat.pag94<-rate.par.drop(rate.mat.ard.4state, drop.par=c(3,5,8,10))
rate.mat.MRL<-rate.par.drop(rate.mat.ard.4state, drop.par=c(2,7))
print(rate.mat.MRL)  
print(rayDISC(primates$tree, fourstate.data, ntraits=1, rate.mat=rate.mat.MRL, node.states="marginal", model="ARD")) 
#AIC 106.1451
rate.mat.MRL2<-rate.par.drop(rate.mat.ard.4state, drop.par=c(1,4))
print(rate.mat.MRL2)  
print(rayDISC(primates$tree, fourstate.data, ntraits=1, rate.mat=rate.mat.MRL2, node.states="marginal", model="ARD"))  
#AIC 122.6322
print(rayDISC(primates$tree, fourstate.data, ntraits=1, rate.mat=rate.mat.er.4state, node.states="marginal", model="ARD")) 
#AIC 107.9277

##Only going through O1 improves the AIC value as opposed to only going through 10. Compared to the original model the AIC is only improved marginally.