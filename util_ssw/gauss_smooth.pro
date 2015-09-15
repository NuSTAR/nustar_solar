;; $Id: //depot/Release/IDL_81/idl/idldir/lib/gauss_smooth.pro#1 $
;;
;; Copyright (c) 2010-2011, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;+
;; Gauss_Smooth
;;
;; Purpose:
;;   This function implements the gaussian smoothing function
;;
;-

;;---------------------------------------------------------------------------
;; Create_gaussian
;;
;; Purpose:
;;   Create a guassian kernal for smoothing
;;
;; Parameters:
;;   SIGMA - sigma value
;;
;;   WIDTH - desired width of the kernel
;;
;;   DIMS - number of dimensions of the kernel, currently only 1 or 2
;;
;; Keywords:
;;   NONE
;;
FUNCTION create_gaussian, sigmaIn, widthIn, dims

  ;; if not specified create a 5x5 1-sigma kernel
  sigma = (n_elements(sigmaIn) EQ 0) ? 1.0d : double(sigmaIn)
  width = (n_elements(widthIn) EQ 0) ? 5 : widthIn
  IF (n_elements(dims) EQ 0) THEN dims = 2
  
  ;; Ensure width is an odd integer
  width = fix(width) > 1
  width += width/2*2 EQ width
  IF ((n_elements(width) EQ 1) && (dims EQ 2)) THEN width = [width,width]
  IF ((n_elements(sigma) EQ 1) && (dims EQ 2)) THEN sigma = [sigma,sigma]

  ;; create X and Y indices
  x = (dindgen(width[0])-width[0]/2)
  IF (dims EQ 2) THEN BEGIN
    x #= replicate(1, width[1])
    y = transpose((dindgen(width[1])-width[1]/2) # $
      replicate(1, width[0]))
 ENDIF

  ;; create kernel
  IF (dims EQ 2) THEN BEGIN
    kernel = exp(-((x^2)/(2*sigma[0]^2)+(y^2)/(2*sigma[1]^2)))
 ENDIF ELSE BEGIN
    kernel = exp(-(x^2)/(2*sigma^2))
 ENDELSE

  return, kernel

END


;;---------------------------------------------------------------------------
;; Gauss_Smooth
;;
;; Purpose:
;;   Main routine
;;
FUNCTION gauss_smooth, data, sigmaIn, $
                       width=widthIn, kernel=gaussKernel, $
                       _EXTRA=_extra

on_error,2

  ;; verify we do have a 1D or 2D input
  dataDims = size(data, /n_dimensions)
  IF ((dataDims LT 1) || (dataDims GT 2)) THEN BEGIN
    message, 'Incorrect input data dimensions'
    return, 0
 ENDIF
  ;; collapse dimensions of 1
  dims = size(data, /dimensions)
  dims1cnt = 0
  IF (dataDims EQ 2) THEN BEGIN
    index = where(dims EQ 1, dims1cnt)
    IF (dims1cnt EQ 1) THEN BEGIN
      dataDims = 1
      ; Ensure no 1's are in any of the data dimensions
      data = reform(data, /OVERWRITE)
   ENDIF
 ENDIF
  
  ;; weed out inappropriate input types
  tname = size(data, /tname)
  IF ((tname EQ 'STRING') || (tname EQ 'STRUCT') || (tname EQ 'POINTER') || $
      (tname EQ 'OBJREF')) THEN BEGIN
    message, 'Incorrect input data type'
    return, 0
 ENDIF

  ;; verify sigma
  sigmaDims = n_elements(sigmaIn)
  IF (sigmaDims GT 2) THEN BEGIN
    message, 'Incorrect sigma specification'
    return, 0
 ENDIF
  IF (sigmaDims EQ 0) THEN $
    sigmaIn = 1.0d
  sigma = sigmaIn
  
  ;; weed out inappropriate sigma types
  tname = size(sigma, /tname)
  IF ((tname EQ 'STRING') || (tname EQ 'STRUCT') || (tname EQ 'POINTER') || $
      (tname EQ 'OBJREF')) THEN BEGIN
    message, 'Incorrect sigma type'
    return, 0
 ENDIF

  IF (sigmaDims GT dataDims) THEN BEGIN
    message, 'Incompatible dimensions for Data and Sigma'
    return, 0
 ENDIF
  
  ;; verify width
  widthDims = n_elements(widthIn)
  IF (widthDims GT 2) THEN BEGIN
    message, 'Incorrect width specification'
    return, 0
 ENDIF
  ;; fill in width if not provided
  IF (widthDims EQ 0) THEN BEGIN
    width = CEIL(sigma*3)
    ;; ensure width is odd
    width += width/2*2 EQ width
    width *= 2
    width++
 ENDIF ELSE BEGIN
    width = widthIn
 ENDELSE
  
  ;; weed out inappropriate width types
  tname = size(widthIn, /tname)
  IF ((tname EQ 'STRING') || (tname EQ 'STRUCT') || (tname EQ 'POINTER') || $
      (tname EQ 'OBJREF')) THEN BEGIN
    message, 'Incorrect width type'
    return, 0
 ENDIF

  IF (widthDims GT dataDims) THEN BEGIN
    message, 'Incompatible dimensions for Data and Width'
    return, 0
 ENDIF
  
  IF (max(size(data, /dimensions) LT width) NE 0) THEN BEGIN
    message, 'Kernel size cannot be larger than the data size'
    return, 0
 ENDIF

  ;; Ensure inputs fall within realistic values
  ((sigma >= 0.1)) <= 99.9

  dataType = size(data, /TYPE)
  gaussKernel = create_gaussian(sigma, width, dataDims)
  ; Kernel must be same data type as input
  gaussKernel = fix(temporary(gaussKernel), TYPE=dataType)

  smoothData = convol(data, gaussKernel, total(gaussKernel), $
                      _EXTRA=_extra)

  ; Put original data dimensions back                      
  IF (dims1cnt EQ 1) THEN $
    data = reform(data, dims, /OVERWRITE)

  return, smoothData

END
