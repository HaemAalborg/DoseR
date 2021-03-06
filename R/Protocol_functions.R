
##
##
## Read a protocol into R
##
##


runDoseR <- function(){
  A.data <- list()
  A.data <<- getwd()
  shiny::runApp(system.file('shiny', package='DoseResponse'))
}

readProtocol <- function(xls.file, mistakeval = "X", perl = "perl"){
  
  filesetup <-  xls.file
  
  is64 <- grepl("64", sessionInfo()[1]$R.version$arch)
  sos  <- grepl("darwin", sessionInfo()[1]$R.version$os)
  
  protocol <- list()
  if(sos){
    protocol[["setup"]] <- read.xls(filesetup, sheet = 1, stringsAsFactors = FALSE)
    protocol[["conc"]]  <- read.xls(filesetup, sheet = 2, stringsAsFactors = FALSE)
  }else{
    if(is64){
      protocol[["setup"]] <- 
        gdata::read.xls(filesetup, sheet = 1,
                        perl = perl, 
                        stringsAsFactors = FALSE)
      protocol[["conc"]]  <- 
        gdata::read.xls(filesetup, sheet = 2,
                        perl = perl, 
                        stringsAsFactors = FALSE)
    }else{
      protocol[["setup"]] <- 
        read.xls(filesetup, colNames = TRUE, sheet = 1, stringsAsFactors = FALSE)
      protocol[["conc"]]  <- 
        read.xls(filesetup, colNames = TRUE, sheet = 2, stringsAsFactors = FALSE)
    }
  }
  
  row.names(protocol[["conc"]]) <- 
    as.character(protocol[["conc"]][, 1])
  
  protocol[["conc"]] <- protocol[["conc"]][, -1]
  
  
  row.names(protocol[["setup"]]) <- 
    as.character(protocol[["setup"]][, 1])
  
  protocol[["setup"]] <- protocol[["setup"]][, -1]
  
  protocol[["conc"]] <- 
    protocol[["conc"]][
      ,!(colnames(protocol[["conc"]]) %in%
           c("X", paste("X", 1: ncol(protocol[["conc"]]), sep = ".")))]
  
  
  protocol[["setup"]] <- 
    protocol[["setup"]][
      ,!(colnames(protocol[["setup"]])[-1] %in%
           c("X", paste("X", 1: ncol(protocol[["setup"]]), sep = ".")))]
  
  return(protocol)
}


##
##
## Edit the protocol associated with a certain dbf file
##
##

editDBFProtocol <- function(A.data, dbf.file = NULL){
  
  protocolvar   <- A.data$call$createMetaData$protocolvar
  identifiervar <- A.data$call$createMetaData$identifier
  dbf.file.var  <- A.data$call$createMetaData$dbf.file.var
  colnames      <- eval(A.data$call$createMetaData$colnames)
  sep           <- eval(A.data$call$createMetaData$sep)
  
  
  file.info <- A.data$auxiliary$file.info
  protocol <- A.data$meta.list$metadata.long[
    A.data$meta.list$metadata.long[, dbf.file.var] == dbf.file, protocolvar]
  
  identifier <- A.data$meta.list$metadata.long[
    A.data$meta.list$metadata.long[, dbf.file.var] == dbf.file, identifiervar]
  
  #########################################
  ## Establish a new name for the protocol 
  exist.files <- dir(as.character(file.info$protocol[protocol, "file.path"]))
  new.name <- paste(protocol,"_", identifier,".xls", sep = "")
  
  if(new.name %in% exist.files){
    i <- 1
    while(new.name %in% exist.files){
      new.name <- paste(protocol,"_", identifier, i, ".xls", sep = "")
      i <- i+1
    }
  }
  
  #########################################
  ## Create the protocol 
  
  file.copy(as.character(file.info$protocol[protocol, "file.full"]),
            file.path(as.character(file.info$protocol[protocol, "file.path"]),
                      new.name))
  
  old.name <-as.character(file.info$dbf[dbf.file, "file"])
  
  wh <- which(colnames == "protocolvar")
  
  split <- strsplit(x=old.name, sep)
  
  for(i in 1:length(split)){
    split[[i]][wh] <- no.extension(new.name)
  }
  
  new.name.dbf <- unlist(lapply(split, function(x) paste(x, collapse = sep)))
  
  # new.name.dbf <- gsub(protocol, no.extension(new.name), old.name)
  
  file.rename(as.character(file.info$dbf[dbf.file, "file.full"]),
              file.path(as.character(file.info$dbf[dbf.file, "file.path"]),
                        new.name.dbf))
  
  #########################################
  ##edit the metadata
  
  wh.long <- A.data$meta.list$metadata.long[, dbf.file.var] == dbf.file
  wh.dbf  <- A.data$meta.list$metadata.long  [, dbf.file.var] == dbf.file
  
  if(any(wh.long)){
    A.data$meta.list$metadata.long[wh.long, dbf.file.var] <- no.extension(new.name.dbf)
    A.data$meta.list$metadata.long[wh.long, protocolvar]  <- no.extension(new.name)
  }
  if(any(wh.dbf)){
    A.data$meta.list$metadata.long[wh.dbf, dbf.file.var] <- no.extension(new.name.dbf)
    A.data$meta.list$metadata.long[wh.dbf, protocolvar]  <- no.extension(new.name)
  }
  
  #####################################
  ## edit the file.info
  
  file.info$dbf[dbf.file, "file"] <- new.name.dbf
  file.info$dbf[dbf.file, "file.full"] <- 
    file.path(as.character(file.info$dbf[dbf.file, "file.path"]),
              new.name.dbf)
  
  rwn <- rownames(file.info$dbf) 
  rwn[dbf.file == rwn]<- no.extension(new.name.dbf)
  rownames(file.info$dbf)  <- rwn
  
  
  file.info$protocol[new.name, ]<-
    file.info$protocol[protocol, ]
  
  file.info$protocol[new.name, "file"] <- new.name
  file.info$protocol[new.name, "file.full"] <- 
    file.path(as.character(file.info$protocol[new.name, "file.path"]),
              new.name)
  
  file.info$protocol[new.name, "last.change"] <- 
    file.info(file.info$protocol[new.name, "file.full"])$mtime
  
  A.data$auxiliary$file.info <- file.info
  
  ################################################
  ### Track changes
  changes <- data.frame(old.dbf.file = dbf.file,
                        new.dbf.file = no.extension(new.name.dbf),
                        old.protocol = protocol,
                        new.protocol = no.extension(new.name),
                        date         = as.character(Sys.time()))
  
  if(is.null(A.data$auxiliary$protocol.changes)){
    A.data$auxiliary$protocol.changes <- changes
  }else{
    changes <- rbind(A.data$auxiliary$protocol.changes,
                     changes)
    A.data$auxiliary$protocol.changes <- changes
  }
  
  ################################
  ### save thechanges
  
  old <- A.data
  save(old, file = A.data$auxiliary$passed.var$data.file)
  
  system2("open", 
          paste("'", file.path(as.character(
            file.info$protocol[protocol, "file.path"]),
                               new.name), "'", 
                sep = ''))
  return(old)
  
}


##
##
## Create a new protocol
##
##

createProtocol <- 
  function(n.doses = 16, n.backgrounds = 6,
           n.controls = 6, fold = 2, max = 60,
           remove.edges = TRUE,
           drug = "drug"){
    
    mat <- matrix(NA, ncol= 12, nrow = 8)
    
    if(remove.edges){
      mat[,c(1, ncol(mat))] <- "M"
      mat[c(1, nrow(mat)),] <- "M"
    }
    
    mat[is.na(mat)][1:n.backgrounds] <- "B"
    mat[is.na(mat)][1:n.controls]    <- "C0"
    
    n.l <- sum(is.na(mat)) 
    n.conc.w <- n.l/n.doses
    
    conc.v <- rep(paste("C", 1:n.doses, sep = ""), each = n.conc.w)
    
    mat[is.na(mat)][1:length(conc.v)] <- conc.v
    
    row.names(mat) <- LETTERS[1:8]
    colnames(mat) <- paste("col",1:12, sep = "")
    setup <- as.data.frame(mat)
    
    
    
    conc <- max
    for(i in 2:n.doses)
      conc[i] <- conc[i-1]/fold   
    
    conc <- data.frame(Concentration = c(rep(0, 3), rev(conc)),
                       Additive = c("Control", "Background", "Medium",
                                    rep(drug, n.doses)),
                       Curve = c(rep(0, 3), rep(1, n.doses)))
    
    
    row.names(conc) <- c("C0", "B", "M", paste("C", 1:n.doses, sep = ""))
    
    list(setup = setup, conc = conc)
  }

##
##
## Internal function that creates a temporary 
## protocol and opens it in Excel. 
## Returns the path to the Excel file   
##
##

editProtocol <- function(protocol){
  tempfile = tempfile()
  
  protocol$conc$Name <- row.names(protocol$conc)
  protocol$conc <- protocol$conc[,c(ncol(protocol$conc), 1:(ncol(protocol$conc)- 1))]
  
  protocol$setup[, " "] <- row.names(protocol$setup)
  protocol$setup <- protocol$setup[,c(ncol(protocol$setup), 1:(ncol(protocol$setup)- 1))]
  
  WriteXLS(names(protocol), ExcelFileName = tempfile,
           row.names=FALSE, col.names=TRUE, 
           SheetNames = names(protocol), 
           BoldHeaderRow = TRUE, 
           Encoding = "UTF-8",
           envir = list2env(protocol),
           FreezeRow = 1, FreezeCol = 1, AdjWidth = TRUE)
  
  
  system2("open", paste("'", tempfile, "'", 
                        sep = ''))
  
  return(tempfile)
}


##
##
## Use a temporary protocol
##
##

useTempProtocol<- function(A.data, protocol = NULL, protocolname, dbf.files){
  if(is.null(protocol))
    protocol <- A.data$data$protocols[[protocolname]]
  
  
  protocolvar   <- A.data$call$createMetaData$protocolvar
  identifiervar <- A.data$call$createMetaData$identifier
  dbf.file.var  <- A.data$call$createMetaData$dbf.file.var
  colnames      <- eval(A.data$call$createMetaData$colnames)
  sep           <- eval(A.data$call$createMetaData$sep)
  
  file.info <- A.data$auxiliary$file.info
  
  prior.protocols <- A.data$meta.list$metadata.long[
    match(dbf.files, A.data$meta.list$metadata.long[, dbf.file.var]), protocolvar]
  
  #########################################
  ## Establish a new name for the protocol 
  exist.files <- dir(as.character(file.info$protocol[prior.protocols, "file.path"]))
  new.name <- paste(protocolname,".xls", sep = "")
  
  if(new.name %in% exist.files){
    i <- 1
    while(new.name %in% exist.files){
      new.name <- paste(protocolname,"_", i, ".xls", sep = "")
      i <- i+1
    }
    warning("The protocol: ", paste(protocolname), " already exist. ",
            "I created a new name for the protocol: ", paste(new.name))
  }
  
  
  
  
  #########################################
  ## Create the protocol DOX16_2 blev brugt foer
  
  old.names <-as.character(file.info$dbf[dbf.files, "file"])
  
  wh <- which(colnames == "protocolvar")
  
  split <- strsplit(x=old.names, sep)
  
  old.protocols <- vector()
  
  for(i in 1:length(split)){
    old.protocols[i] <-split[[i]][wh]
    split[[i]][wh] <- no.extension(new.name)
  }
  new.names <- unlist(lapply(split, function(x) paste(x, collapse = sep)))
  
  file.rename(as.character(file.info$dbf[dbf.files, "file.full"]),
              file.path(as.character(file.info$dbf[dbf.files, "file.path"]),
                        new.names))
  
  
  
  
  #########################################
  ##edit the metadata
  
  wh.long <- match(dbf.files, A.data$meta.list$metadata.long[, dbf.file.var])
  wh.dbf  <- match(dbf.files, A.data$meta.list$metadata.long[, dbf.file.var])
  
  if(any(wh.long)){
    A.data$meta.list$metadata.long[wh.long, dbf.file.var] <- no.extension.vec(new.names)
    A.data$meta.list$metadata.long[wh.long, protocolvar]  <- no.extension(new.name)
  }
  if(any(wh.dbf)){
    A.data$meta.list$metadata.long[wh.dbf, dbf.file.var] <- no.extension.vec(new.names)
    A.data$meta.list$metadata.long[wh.dbf, protocolvar]  <- no.extension(new.name)
  }
  
  
  #####################################
  ## edit the file.info
  
  file.info$dbf[dbf.files, "file"] <- new.names
  file.info$dbf[dbf.files, "file.full"] <- 
    file.path(as.character(file.info$dbf[dbf.files, "file.path"]),
              new.names)
  
  rwn <- rownames(file.info$dbf) 
  rwn[match(dbf.files,rwn)]<- no.extension.vec(new.names)
  rownames(file.info$dbf)  <- rwn
  
  
  file.info$protocol[no.extension(new.name), ] <-
    file.info$protocol[prior.protocols, ][1,]
  
  file.info$protocol[no.extension(new.name), "file"] <- new.name
  file.info$protocol[no.extension(new.name), "file.full"] <- 
    file.path(as.character(file.info$protocol[no.extension(new.name), "file.path"]),
              new.name)
  
  file.info$protocol[no.extension(new.name), "last.change"] <- 
    file.info(file.info$protocol[no.extension(new.name), "file.full"])$mtime
  
  A.data$auxiliary$file.info <- file.info
  
  
  ##################################
  ## save the protocol
  
  
  xls.file = file.path(
    file.info$protocol[no.extension(new.name), "file.path",],
    new.name)
  
  WriteXLS(names(protocol), ExcelFileName = xls.file,
           row.names=TRUE, col.names=TRUE, 
           SheetNames = names(protocol), 
           BoldHeaderRow = TRUE, 
           Encoding = "UTF-8",
           envir = list2env(protocol),
           FreezeRow = 1, FreezeCol = 1, AdjWidth = TRUE)
  
  ################################################
  ### Track changes
  changes <- data.frame(old.dbf.file = dbf.files,
                        new.dbf.file = no.extension.vec(new.names),
                        old.protocol = old.protocols,
                        new.protocol = no.extension(new.name),
                        date         = as.character(Sys.time()))
  
  
  if(is.null(A.data$auxiliary$protocol.changes)){
    A.data$auxiliary$protocol.changes <- changes
  }else{
    changes <- rbind(A.data$auxiliary$protocol.changes,
                     changes)
    A.data$auxiliary$protocol.changes <- changes
  }
  
  ################################
  ### save thechanges
  
  A.data$data$protocols[[new.name]] <- protocol
  
  old <- A.data
  save(old, file = A.data$auxiliary$passed.var$data.file)
  
  return(old)
}

##
##
## Use a created protocol
##
##

useNewProtocol<- function(A.data, protocol = NULL, protocolname, dbf.files){
  if(is.null(protocol))
    protocol <- A.data$data$protocols[[protocolname]]
  
  
  protocolvar   <- A.data$call$createMetaData$protocolvar
  identifiervar <- A.data$call$createMetaData$identifier
  dbf.file.var  <- A.data$call$createMetaData$dbf.file.var
  colnames      <- eval(A.data$call$createMetaData$colnames)
  sep           <- eval(A.data$call$createMetaData$sep)
  
  file.info <- A.data$auxiliary$file.info
  
  prior.protocols <- A.data$meta.list$metadata.long[
    match(dbf.files, A.data$meta.list$metadata.long[, dbf.file.var]), protocolvar]
  
  #########################################
  ## Establish a new name for the protocol 
  exist.files <- dir(as.character(file.info$protocol[prior.protocols, "file.path"]))
  new.name <- paste(protocolname,".xls", sep = "")
  
  if(new.name %in% exist.files){
    i <- 1
    while(new.name %in% exist.files){
      new.name <- paste(protocolname,"_", i, ".xls", sep = "")
      i <- i+1
    }
    warning("The protocol: ", paste(protocolname), " already exist. ",
            "I created a new name for the protocol: ", paste(new.name))
  }
  
  
  
  
  #########################################
  ## Create the protocol DOX16_2 blev brugt fooer
  
  old.names <-as.character(file.info$dbf[dbf.files, "file"])
  
  wh <- which(colnames == "protocolvar")
  
  split <- strsplit(x=old.names, sep)
  
  old.protocols <- vector()
  
  for(i in 1:length(split)){
    old.protocols[i] <-split[[i]][wh]
    split[[i]][wh] <- no.extension(new.name)
  }
  new.names <- unlist(lapply(split, function(x) paste(x, collapse = sep)))
  
  file.rename(as.character(file.info$dbf[dbf.files, "file.full"]),
              file.path(as.character(file.info$dbf[dbf.files, "file.path"]),
                        new.names))
  
  
  
  
  #########################################
  ##edit the metadata
  
  wh.long <- match(dbf.files, A.data$meta.list$metadata.long[, dbf.file.var])
  wh.dbf  <- match(dbf.files, A.data$meta.list$metadata.long[, dbf.file.var])
  
  if(any(wh.long)){
    A.data$meta.list$metadata.long[wh.long, dbf.file.var] <- no.extension.vec(new.names)
    A.data$meta.list$metadata.long[wh.long, protocolvar]  <- no.extension(new.name)
  }
  if(any(wh.dbf)){
    A.data$meta.list$metadata.long[wh.dbf, dbf.file.var] <- no.extension.vec(new.names)
    A.data$meta.list$metadata.long[wh.dbf, protocolvar]  <- no.extension(new.name)
  }
  
  
  #####################################
  ## edit the file.info
  
  file.info$dbf[dbf.files, "file"] <- new.names
  file.info$dbf[dbf.files, "file.full"] <- 
    file.path(as.character(file.info$dbf[dbf.files, "file.path"]),
              new.names)
  
  rwn <- rownames(file.info$dbf) 
  rwn[match(dbf.files,rwn)]<- no.extension.vec(new.names)
  rownames(file.info$dbf)  <- rwn
  
  
  file.info$protocol[no.extension(new.name), ] <-
    file.info$protocol[prior.protocols, ][1,]
  
  file.info$protocol[no.extension(new.name), "file"] <- new.name
  file.info$protocol[no.extension(new.name), "file.full"] <- 
    file.path(as.character(file.info$protocol[no.extension(new.name), "file.path"]),
              new.name)
  
  file.info$protocol[no.extension(new.name), "last.change"] <- 
    file.info(file.info$protocol[no.extension(new.name), "file.full"])$mtime
  
  A.data$auxiliary$file.info <- file.info
  
  
  ##################################
  ## save the protocol
  
  
  xls.file = file.path(
    file.info$protocol[no.extension(new.name), "file.path",],
    new.name)
  
  WriteXLS(names(protocol), ExcelFileName = xls.file,
           row.names=TRUE, col.names=TRUE, 
           SheetNames = names(protocol), 
           BoldHeaderRow = TRUE, 
           Encoding = "UTF-8",
           envir = list2env(protocol),
           FreezeRow = 1, FreezeCol = 1, AdjWidth = TRUE)
  
  
  system2("open", paste("'", file.path(as.character(
    file.info$protocol[no.extension(new.name), "file.path"]),
                                       new.name), "'", 
                        sep = ''))
  
  ################################################
  ### Track changes
  changes <- data.frame(old.dbf.file = dbf.files,
                        new.dbf.file = no.extension.vec(new.names),
                        old.protocol = old.protocols,
                        new.protocol = no.extension(new.name),
                        date         = as.character(Sys.time()))
  
  
  if(is.null(A.data$auxiliary$protocol.changes)){
    A.data$auxiliary$protocol.changes <- changes
  }else{
    changes <- rbind(A.data$auxiliary$protocol.changes,
                     changes)
    A.data$auxiliary$protocol.changes <- changes
  }
  
  ################################
  ### save thechanges
  
  A.data$data$protocols[[new.name]] <- protocol
  
  old <- A.data
  save(old, file = A.data$auxiliary$passed.var$data.file)
  
  return(old)
}

##
##
## Use an existing protocol with a existing dbf.file
##
##


useExistingProtocol<- function(A.data, protocolname, dbf.files){
  
  protocolvar   <- A.data$call$createMetaData$protocolvar
  identifiervar <- A.data$call$createMetaData$identifier
  dbf.file.var  <- A.data$call$createMetaData$dbf.file.var
  colnames      <- eval(A.data$call$createMetaData$colnames)
  sep           <- eval(A.data$call$createMetaData$sep)
  
  file.info <- A.data$auxiliary$file.info
  
  prior.protocols <- A.data$meta.list$metadata.long[
    match(dbf.files, A.data$meta.list$metadata.long[, dbf.file.var]), protocolvar]
  
  new.name<-paste(protocolname, ".xls", sep = "")
  
  #########################################
  ## Create the protocol DOX16_2 blev brugt foer
  
  old.names <-as.character(file.info$dbf[dbf.files, "file"])
  
  wh <- which(colnames == "protocolvar")
  
  split <- strsplit(x=old.names, sep)
  
  old.protocols <- vector()
  
  for(i in 1:length(split)){
    old.protocols[i] <-split[[i]][wh]
    split[[i]][wh] <- no.extension(new.name)
  }
  new.names <- unlist(lapply(split, function(x) paste(x, collapse = sep)))
  
  file.rename(as.character(file.info$dbf[dbf.files, "file.full"]),
              file.path(as.character(file.info$dbf[dbf.files, "file.path"]),
                        new.names))
  
  
  #########################################
  ##edit the metadata
  
  wh.long <- match(dbf.files, A.data$meta.list$metadata.long[, dbf.file.var])
  wh.dbf  <- match(dbf.files, A.data$meta.list$metadata.long[, dbf.file.var])
  
  if(any(wh.long)){
    A.data$meta.list$metadata.long[wh.long, dbf.file.var] <- no.extension.vec(new.names)
    A.data$meta.list$metadata.long[wh.long, protocolvar]  <- no.extension(new.name)
  }
  if(any(wh.dbf)){
    A.data$meta.list$metadata.long[wh.dbf, dbf.file.var] <- no.extension.vec(new.names)
    A.data$meta.list$metadata.long[wh.dbf, protocolvar]  <- no.extension(new.name)
  }
  
  
  #####################################
  ## edit the file.info
  
  file.info$dbf[dbf.files, "file"] <- new.names
  file.info$dbf[dbf.files, "file.full"] <- 
    file.path(as.character(file.info$dbf[dbf.files, "file.path"]),
              new.names)
  
  rwn <- rownames(file.info$dbf) 
  rwn[match(dbf.files,rwn)]<- no.extension.vec(new.names)
  rownames(file.info$dbf)  <- rwn
  
  
  A.data$auxiliary$file.info <- file.info
  
  
  ################################################
  ### Track changes
  changes <- data.frame(old.dbf.file = dbf.files,
                        new.dbf.file = no.extension.vec(new.names),
                        old.protocol = old.protocols,
                        new.protocol = no.extension(new.name),
                        date         = as.character(Sys.time()))
  
  
  if(is.null(A.data$auxiliary$protocol.changes)){
    A.data$auxiliary$protocol.changes <- changes
  }else{
    changes <- rbind(A.data$auxiliary$protocol.changes,
                     changes)
    
    A.data$auxiliary$protocol.changes <- changes
  }
  
  ################################
  ### save thechanges
  
  old <- A.data
  save(old, file = A.data$auxiliary$passed.var$data.file)
  
  return(old)
}
