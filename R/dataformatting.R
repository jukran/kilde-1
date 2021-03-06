##' dataformatting
##'
##' A function that formats the input data to be submittable to the
##' mcmc and initialization functions
##' @title data formatting
##' @param DATA A data set
##' @param UM An integer 0, 1, 2. Choose 0 for setting 0 as 'data
##'     sample' for unknown source. Choose 1 for taking the mean type
##'     frequencies as 'data sample' for unknown source. Choose 2 for
##'     taking the type frequencies drawn from the STs that were
##'     unique to humans, as 'data sample' for unknown source.
##' @return A list of objects that will be passed to the mcmc and
##'     initializer
##' @author Jukka Ranta
##' @export
dataformatting <- function(DATA, UM) {
    if(!all(c("ST", "group", "ASP", "GLN", "GLT", "GLY", "PGM", "TKT",
              "UNC") %in% names(DATA))){
        stop("DATA must contain at least the columns: ST and group")
    }
    if(!is.factor(DATA$group)){
        stop("The group variable must be a factor")
    }
    if(!("human" %in% levels(DATA$group))){
        stop("The group variable must have a level 'human'")
    }
    if(length(DATA$group[DATA$group == "human"]) < 1){
        stop("There must be greater than 0 'human' observations in the data")
    }
    z <- !is.na(DATA$ST)
    sourcenames <- setdiff(unique(DATA$group), "human")
    ns <- length(sourcenames)

    ## find how many different STs there are (in all isolates), and list them:
    STu <- sort(unique(DATA$ST[z]))
    STuH <- sort(unique(DATA$ST[z & (DATA$group == "human")]))
    STuS <- sort(unique(DATA$ST[z & (DATA$group != "human")]))
    STuHo <- setdiff(STuH, STuS) 

    HumanST <- DATA$ST[z & (DATA$group == "human")]
    Humnovel <- 0
    for(i in 1:length(HumanST)){
        Humnovel <- Humnovel + is.element(HumanST[i], STuHo) * 1
    }
    ## Sample probability to see ST in Human isolates that was not seen in sources: 
    PUNST <- Humnovel / length(HumanST)

    ## make a table of STs and corresponding alleles:
    STtable<- matrix(NA, length(STu), 8)
    for(i in 1:length(STu)){
        STtable[i, 1] <- STu[i]
        STtable[i, 2] <- unique(DATA$ASP[(DATA$ST == STu[i]) & !is.na(DATA$ST)])
        STtable[i, 3] <- unique(DATA$GLN[(DATA$ST == STu[i]) & !is.na(DATA$ST)])
        STtable[i, 4] <- unique(DATA$GLT[(DATA$ST == STu[i]) & !is.na(DATA$ST)])
        STtable[i, 5] <- unique(DATA$GLY[(DATA$ST == STu[i]) & !is.na(DATA$ST)])
        STtable[i, 6] <- unique(DATA$PGM[(DATA$ST == STu[i]) & !is.na(DATA$ST)])
        STtable[i, 7] <- unique(DATA$TKT[(DATA$ST == STu[i]) & !is.na(DATA$ST)])
        STtable[i, 8] <- unique(DATA$UNC[(DATA$ST == STu[i]) & !is.na(DATA$ST)])
    }

    ## find how many different a-types there are, and list them:
    ASPu <- sort(unique(STtable[,2]))
    GLNu <- sort(unique(STtable[,3]))
    GLTu <- sort(unique(STtable[,4]))
    GLYu <- sort(unique(STtable[,5]))
    PGMu <- sort(unique(STtable[,6]))
    TKTu <- sort(unique(STtable[,7]))
    UNCu <- sort(unique(STtable[,8]))

    nat <- numeric()  # number of all different alleles
    nat[1] <- length(ASPu) 
    nat[2] <- length(GLNu)
    nat[3] <- length(GLTu)
    nat[4] <- length(GLYu)
    nat[5] <- length(PGMu)
    nat[6] <- length(TKTu)
    nat[7] <- length(UNCu)

    ## number (counts) of a-types in each source:
    ## define "unknown source" (ns+1) 
    maxns <- ns + 1
    sourcesASP <- matrix(0,maxns,length(ASPu)) 
    sourcesGLN <- matrix(0,maxns,length(GLNu))
    sourcesGLT <- matrix(0,maxns,length(GLTu))
    sourcesGLY <- matrix(0,maxns,length(GLYu))
    sourcesPGM <- matrix(0,maxns,length(PGMu))
    sourcesTKT <- matrix(0,maxns,length(TKTu))
    sourcesUNC <- matrix(0,maxns,length(UNCu))

    ## number (counts) of such a-types in humans & also found in sources:
    humansASP <- numeric()
    humansGLN <- numeric()
    humansGLT <- numeric()
    humansGLY <- numeric()
    humansPGM <- numeric()
    humansTKT <- numeric()
    humansUNC <- numeric()

    ## sample frequencies (counts) of each a-type
    for(i in 1:length(ASPu)){
        humansASP[i] <- sum((DATA$ASP == ASPu[i]) & (DATA$group == "human") & z)
        for(j in 1:ns){
            sourcesASP[j, i] <- sum((DATA$ASP == ASPu[i]) & (DATA$group == sourcenames[j]) & z)
        }
    }
    for(i in 1:length(GLNu)){
        humansGLN[i] <- sum((DATA$GLN == GLNu[i]) & (DATA$group == "human") & z)
        for(j in 1:ns){
            sourcesGLN[j, i] <- sum((DATA$GLN == GLNu[i]) & (DATA$group == sourcenames[j]) & z)
        }
    }
    for(i in 1:length(GLTu)){
        humansGLT[i] <- sum((DATA$GLT == GLTu[i]) & (DATA$group == "human") & z)
        for(j in 1:ns){
            sourcesGLT[j, i] <- sum((DATA$GLT==GLTu[i])&(DATA$group==sourcenames[j]) & z)
        }
    }
    for(i in 1:length(GLYu)){
        humansGLY[i] <- sum((DATA$GLY == GLYu[i]) & (DATA$group == "human") & z)
        for(j in 1:ns){
            sourcesGLY[j, i] <- sum((DATA$GLY == GLYu[i]) & (DATA$group == sourcenames[j]) & z)
        }
    }
    for(i in 1:length(PGMu)){
        humansPGM[i] <-sum((DATA$PGM == PGMu[i]) & (DATA$group == "human") & z)
        for(j in 1:ns){ 
            sourcesPGM[j, i] <- sum((DATA$PGM == PGMu[i]) & (DATA$group == sourcenames[j]) & z)
        }
    }
    for(i in 1:length(TKTu)){
        humansTKT[i] <- sum((DATA$TKT == TKTu[i]) & (DATA$group == "human") & z)
        for(j in 1:ns){
            sourcesTKT[j, i] <- sum((DATA$TKT == TKTu[i]) & (DATA$group == sourcenames[j]) & z)
        }
    }
    for(i in 1:length(UNCu)){
        humansUNC[i] <- sum((DATA$UNC == UNCu[i]) & (DATA$group == "human") & z)
        for(j in 1:ns){
            sourcesUNC[j, i] <- sum((DATA$UNC == UNCu[i]) & (DATA$group == sourcenames[j]) & z)
        }
    }
    ## Number of all human isolates:
    Nisolates <- sum(z & (DATA$group=="human"))

    ## Get allele numbers for each human isolate:
    HumanASP <- DATA$ASP[z & (DATA$group == "human")]
    HumanGLN <- DATA$GLN[z & (DATA$group == "human")]
    HumanGLT <- DATA$GLT[z & (DATA$group == "human")]
    HumanGLY <- DATA$GLY[z & (DATA$group == "human")]
    HumanPGM <- DATA$PGM[z & (DATA$group == "human")]
    HumanTKT <- DATA$TKT[z & (DATA$group == "human")]
    HumanUNC <- DATA$UNC[z & (DATA$group == "human")]

    positionASP <- 1:length(ASPu)
    IASP <- matrix(0,Nisolates,nat[1])
    positionGLN <- 1:length(GLNu)
    IGLN <- matrix(0,Nisolates,nat[2])
    positionGLT <- 1:length(GLTu)
    IGLT <- matrix(0,Nisolates,nat[3])
    positionGLY <- 1:length(GLYu)
    IGLY <- matrix(0,Nisolates,nat[4])
    positionPGM <- 1:length(PGMu)
    IPGM <- matrix(0,Nisolates,nat[5])
    positionTKT <- 1:length(TKTu)
    ITKT <- matrix(0,Nisolates,nat[6])
    positionUNC <- 1:length(UNCu)
    IUNC <- matrix(0,Nisolates,nat[7])
    for(i in 1:Nisolates){
        IASP[i,positionASP[ASPu==HumanASP[i]]] <- 1 
        IGLN[i,positionGLN[GLNu==HumanGLN[i]]] <- 1 
        IGLT[i,positionGLT[GLTu==HumanGLT[i]]] <- 1 
        IGLY[i,positionGLY[GLYu==HumanGLY[i]]] <- 1 
        IPGM[i,positionPGM[PGMu==HumanPGM[i]]] <- 1 
        ITKT[i,positionTKT[TKTu==HumanTKT[i]]] <- 1 
        IUNC[i,positionUNC[UNCu==HumanUNC[i]]] <- 1 
    }

    ## build index for allele types of the ith isolate:
    ind <- matrix(0, Nisolates,7)
    prodIASP<-numeric()
    prodIGLN<-numeric()
    prodIGLT<-numeric()
    prodIGLY<-numeric()
    prodIPGM<-numeric()
    prodITKT<-numeric()
    prodIUNC<-numeric()
    for(i in 1:Nisolates){
        for(j in 1:nat[1]){prodIASP[j] <- IASP[i,j]*j}
        ind[i,1] <- sum(prodIASP[])
        for(j in 1:nat[2]){prodIGLN[j] <- IGLN[i,j]*j}
        ind[i,2] <- sum(prodIGLN[])
        for(j in 1:nat[3]){prodIGLT[j] <- IGLT[i,j]*j}
        ind[i,3] <- sum(prodIGLT[])
        for(j in 1:nat[4]){prodIGLY[j] <- IGLY[i,j]*j}
        ind[i,4] <- sum(prodIGLY[])
        for(j in 1:nat[5]){prodIPGM[j] <- IPGM[i,j]*j}
        ind[i,5] <- sum(prodIPGM[])
        for(j in 1:nat[6]){prodITKT[j] <- ITKT[i,j]*j}
        ind[i,6] <- sum(prodITKT[])
        for(j in 1:nat[7]){prodIUNC[j] <- IUNC[i,j]*j}
        ind[i,7] <- sum(prodIUNC[])
    }

    ns <- maxns  ## one "unknown source" added, with data sample zero, or the following:

    ## If UM=1, set the average sample as "data" for the unknown source:
    if(UM==1){   
        for(j in 1:nat[1]){sourcesASP[ns, j] <- round(mean(sourcesASP[1:ns - 1, j]))}
        for(j in 1:nat[2]){sourcesGLN[ns, j] <- round(mean(sourcesGLN[1:ns - 1, j]))}
        for(j in 1:nat[3]){sourcesGLT[ns, j] <- round(mean(sourcesGLT[1:ns - 1, j]))}
        for(j in 1:nat[4]){sourcesGLY[ns, j] <- round(mean(sourcesGLY[1:ns - 1, j]))}
        for(j in 1:nat[5]){sourcesPGM[ns, j] <- round(mean(sourcesPGM[1:ns - 1, j]))}
        for(j in 1:nat[6]){sourcesTKT[ns, j] <- round(mean(sourcesTKT[1:ns - 1, j]))}
        for(j in 1:nat[7]){sourcesUNC[ns, j] <- round(mean(sourcesUNC[1:ns - 1, j]))}
    }

    if(UM==2){
        ## This will set the allele counts for the "unknown source sample" 
        ## such that it represents the counts drawn from STs that were unique to humans.
        for(j in 1:length(STu)){
            sourcesASP[ns, positionASP[ASPu == STtable[j, 2]]] <- sourcesASP[ns, positionASP[ASPu==STtable[j,2]]] + sum((DATA$ST==STu[j]) & is.element(STu[j],STuHo) & (DATA$group=="human")  & z) 
        }
        for(j in 1:length(STu)){
            sourcesGLN[ns, positionGLN[GLNu == STtable[j, 3]]] <- sourcesGLN[ns, positionGLN[GLNu==STtable[j,3]]] + sum((DATA$ST==STu[j]) & is.element(STu[j],STuHo) & (DATA$group=="human")  & z) 
        }
        for(j in 1:length(STu)){
            sourcesGLT[ns, positionGLT[GLTu == STtable[j, 4]]] <- sourcesGLT[ns, positionGLT[GLTu==STtable[j,4]]] + sum((DATA$ST==STu[j]) & is.element(STu[j],STuHo) & (DATA$group=="human")  & z) 
        }
        for(j in 1:length(STu)){
            sourcesGLY[ns, positionGLY[GLYu == STtable[j, 5]]] <- sourcesGLY[ns, positionGLY[GLYu==STtable[j,5]]] + sum((DATA$ST==STu[j]) & is.element(STu[j],STuHo) & (DATA$group=="human")  & z) 
        }
        for(j in 1:length(STu)){
            sourcesPGM[ns, positionPGM[PGMu == STtable[j, 6]]] <- sourcesPGM[ns, positionPGM[PGMu==STtable[j,6]]] + sum((DATA$ST==STu[j]) & is.element(STu[j],STuHo) & (DATA$group=="human")  & z) 
        }
        for(j in 1:length(STu)){
            sourcesTKT[ns, positionTKT[TKTu == STtable[j, 7]]] <- sourcesTKT[ns, positionTKT[TKTu==STtable[j,7]]] + sum((DATA$ST==STu[j]) & is.element(STu[j],STuHo) & (DATA$group=="human")  & z) 
        }
        for(j in 1:length(STu)){
            sourcesUNC[ns, positionUNC[UNCu == STtable[j, 8]]] <- sourcesUNC[ns, positionUNC[UNCu==STtable[j,8]]] + sum((DATA$ST==STu[j]) & is.element(STu[j],STuHo) & (DATA$group=="human")  & z) 
        }
    }
    data <- list(sourcenames = sourcenames, ind = ind,
                 sourcesASP = sourcesASP, IASP = IASP,
                 sourcesGLN = sourcesGLN, IGLN = IGLN,
                 sourcesGLT = sourcesGLT, IGLT = IGLT,
                 sourcesGLY = sourcesGLY, IGLY = IGLY,
                 sourcesPGM = sourcesPGM, IPGM = IPGM,
                 sourcesTKT = sourcesTKT, ITKT = ITKT,
                 sourcesUNC = sourcesUNC, IUNC = IUNC,
                 humansASP = humansASP,
                 humansGLN = humansGLN,
                 humansGLT = humansGLT,
                 humansGLY = humansGLY,
                 humansPGM = humansPGM,
                 humansTKT = humansTKT,
                 humansUNC = humansUNC)
    inits <- list(ns = ns, nat = nat,
                  Nisolates = Nisolates)
    result <- list(data = data,
                   inits = inits)
    return(result)
    }


