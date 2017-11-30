import numpy as np


def affine_forward(x, w, b):
  """
  Computes the forward pass for an affine (fully-connected) layer.

  The input x has shape (N, d_1, ..., d_k) and contains a minibatch of N
  examples, where each example x[i] has shape (d_1, ..., d_k). We will
  reshape each input into a vector of dimension D = d_1 * ... * d_k, and
  then transform it to an output vector of dimension M.

  Inputs:
  - x: A numpy array containing input data, of shape (N, d_1, ..., d_k)
  - w: A numpy array of weights, of shape (D, M)
  - b: A numpy array of biases, of shape (M,)

  Returns a tuple of:
  - out: output, of shape (N, M)
  - cache: (x, w, b)
  """
  out = None
  X = x.reshape(x.shape[0], -1)
  out = X.dot(w) + b
  cache = (x, w, b)
  return out, cache


def affine_backward(dout, cache):
  """
  Computes the backward pass for an affine layer.

  Inputs:
  - dout: Upstream derivative, of shape (N, M)
  - cache: Tuple of:
    - x: Input data, of shape (N, d_1, ... d_k)
    - w: Weights, of shape (D, M)

  Returns a tuple of:
  - dx: Gradient with respect to x, of shape (N, d1, ..., d_k)
  - dw: Gradient with respect to w, of shape (D, M)
  - db: Gradient with respect to b, of shape (M,)
  """
  x, w, b = cache
  dx, dw, db = None, None, None
  dx = dout.dot(w.T).reshape(*x.shape)
  dw = x.reshape(x.shape[0], -1).T.dot(dout)
  db = np.sum(dout, axis = 0)
  return dx, dw, db


def relu_forward(x):
  """
  Computes the forward pass for a layer of rectified linear units (ReLUs).

  Input:
  - x: Inputs, of any shape

  Returns a tuple of:
  - out: Output, of the same shape as x
  - cache: x
  """
  out = None
  out = np.maximum(0, x)
  cache = x
  return out, cache


def relu_backward(dout, cache):
  """
  Computes the backward pass for a layer of rectified linear units (ReLUs).

  Input:
  - dout: Upstream derivatives, of any shape
  - cache: Input x, of same shape as dout

  Returns:
  - dx: Gradient with respect to x
  """
  dx, x = None, cache
  mask = x <= 0
  dx = np.where(x > 0, dout, 0)
  return dx


def batchnorm_forward(x, gamma, beta, bn_param):
  """
  Forward pass for batch normalization.

  During training the sample mean and (uncorrected) sample variance are
  computed from minibatch statistics and used to normalize the incoming data.
  During training we also keep an exponentially decaying running mean of the mean
  and variance of each feature, and these averages are used to normalize data
  at test-time.

  At each timestep we update the running averages for mean and variance using
  an exponential decay based on the momentum parameter:

  running_mean = momentum * running_mean + (1 - momentum) * sample_mean
  running_var = momentum * running_var + (1 - momentum) * sample_var

  Note that the batch normalization paper suggests a different test-time
  behavior: they compute sample mean and variance for each feature using a
  large number of training images rather than using a running average. For
  this implementation we have chosen to use running averages instead since
  they do not require an additional estimation step; the torch7 implementation
  of batch normalization also uses running averages.

  Input:
  - x: Data of shape (N, D)
  - gamma: Scale parameter of shape (D,)
  - beta: Shift paremeter of shape (D,)
  - bn_param: Dictionary with the following keys:
    - mode: 'train' or 'test'; required
    - eps: Constant for numeric stability
    - momentum: Constant for running mean / variance.
    - running_mean: Array of shape (D,) giving running mean of features
    - running_var Array of shape (D,) giving running variance of features

  Returns a tuple of:
  - out: of shape (N, D)
  - cache: A tuple of values needed in the backward pass
  """
  mode = bn_param['mode']
  eps = bn_param.get('eps', 1e-5)
  momentum = bn_param.get('momentum', 0.9)

  N, D = x.shape
  running_mean = bn_param.get('running_mean', np.zeros(D, dtype=x.dtype))
  running_var = bn_param.get('running_var', np.zeros(D, dtype=x.dtype))

  out, cache = None, None
  if mode == 'train':
    X_mean = np.mean(x, axis = 0, keepdims = True)
    X_var = np.var(x, axis = 0, keepdims = True)
    denom = np.sqrt(X_var + eps)
    X_normalized = (x - X_mean) / denom
    out = gamma * X_normalized + beta
    cache = {'X': x,
            'X_normalized': X_normalized,
            'gamma': gamma,
            'beta': beta,
            'mean': X_mean,
            'var': X_var,
            'eps': eps,
            'denom': denom}

    running_mean = momentum * running_mean + (1 - momentum) * X_mean
    running_var = momentum * running_var + (1 - momentum) * X_var
  elif mode == 'test':
    X_normalized = (x - running_mean) / np.sqrt(running_var + eps)
    out = gamma * X_normalized + beta
    cache = {'X': x,
            'X_normalized': X_normalized,
            'gamma': gamma,
            'beta': beta,
            'eps': eps}
  else:
    raise ValueError('Invalid forward batchnorm mode "%s"' % mode)

  # Store the updated running means back into bn_param
  bn_param['running_mean'] = running_mean
  bn_param['running_var'] = running_var

  return out, cache


def batchnorm_backward(dout, cache):
  """
  Backward pass for batch normalization.

  For this implementation, you should write out a computation graph for
  batch normalization on paper and propagate gradients backward through
  intermediate nodes.

  Inputs:
  - dout: Upstream derivatives, of shape (N, D)
  - cache: Variable of intermediates from batchnorm_forward.

  Returns a tuple of:
  - dx: Gradient with respect to inputs x, of shape (N, D)
  - dgamma: Gradient with respect to scale parameter gamma, of shape (D,)
  - dbeta: Gradient with respect to shift parameter beta, of shape (D,)
  """
  dx, dgamma, dbeta = None, None, None
  X = cache['X']
  N = X.shape[0]
  X_normalized = cache['X_normalized']
  gamma = cache['gamma']
  beta = cache['beta']
  mean = cache['mean']
  var = cache['var']
  eps = cache['eps']
  denom = cache['denom']

  dxzero = dout * gamma
  dvar = np.sum(dxzero * (X - mean) * (-0.5) * np.power(var + eps,
          -1.5), axis = 0)
  dmean = np.sum(dxzero * (-1) / denom, axis = 0) + dvar * (-2 * np.sum(X -
      mean, axis = 0)) / N
  dx = dxzero / denom + dvar * 2 * (X - mean) / N + dmean / N
  dgamma = np.sum(dout * X_normalized, axis = 0)
  dbeta = np.sum(dout, axis = 0)

  return dx, dgamma, dbeta


def dropout_forward(x, dropout_param):
  """
  Performs the forward pass for (inverted) dropout.

  Inputs:
  - x: Input data, of any shape
  - dropout_param: A dictionary with the following keys:
    - p: Dropout parameter. We drop each neuron output with probability p.
    - mode: 'test' or 'train'. If the mode is train, then perform dropout;
      if the mode is test, then just return the input.
    - seed: Seed for the random number generator. Passing seed makes this
      function deterministic, which is needed for gradient checking but not in
      real networks.

  Outputs:
  - out: Array of the same shape as x.
  - cache: A tuple (dropout_param, mask). In training mode, mask is the dropout
    mask that was used to multiply the input; in test mode, mask is None.
  """
  p, mode = dropout_param['p'], dropout_param['mode']
  if 'seed' in dropout_param:
    np.random.seed(dropout_param['seed'])

  mask = None
  out = None

  if mode == 'train':
    mask = (np.random.rand(*x.shape) < p) / p
    out = x * mask
  elif mode == 'test':
    out = x

  cache = (dropout_param, mask)
  out = out.astype(x.dtype, copy=False)

  return out, cache


def dropout_backward(dout, cache):
  """
  Perform the backward pass for (inverted) dropout.

  Inputs:
  - dout: Upstream derivatives, of any shape
  - cache: (dropout_param, mask) from dropout_forward.
  """
  dropout_param, mask = cache
  mode = dropout_param['mode']

  dx = None
  if mode == 'train':
    dx = dout * mask
  elif mode == 'test':
    dx = dout
  return dx


def conv_forward_naive(x, w, b, conv_param):
  """
  A naive implementation of the forward pass for a convolutional layer.

  The input consists of N data points, each with C channels, height H and width
  W. We convolve each input with F different filters, where each filter spans
  all C channels and has height HH and width WW.

  Input:
  - x: Input data of shape (N, C, H, W)
  - w: Filter weights of shape (F, C, HH, WW)
  - b: Biases, of shape (F,)
  - conv_param: A dictionary with the following keys:
    - 'stride': The number of pixels between adjacent receptive fields in the
      horizontal and vertical directions.
    - 'pad': The number of pixels that will be used to zero-pad the input.

  Returns a tuple of:
  - out: Output data, of shape (N, F, H', W') where H' and W' are given by
    H' = 1 + (H + 2 * pad - HH) / stride
    W' = 1 + (W + 2 * pad - WW) / stride
  - cache: (x, w, b, conv_param)
  """
  out = None

  stride = conv_param['stride']
  pad = conv_param['pad']
  padt = (pad, pad)
  N, C, H, W = x.shape
  F, _, HH, WW = w.shape
  H_ = 1 + (H + 2 * pad - HH) / stride
  W_ = 1 + (W + 2 * pad - WW) / stride

  x_padded = np.pad(x, ((0, 0), (0, 0), padt, padt), 'constant')
  _, _, pH, pW = x_padded.shape

  out = np.zeros((N, F, H_, W_))

  for i in xrange(N):
    xi = x_padded[i]
    for f in xrange(F):
      w0 = w[f]
      b0 = b[f]
      j = 0
      nj = 0
      while j + WW <= pW:
        k = 0
        nk = 0
        while k + HH <= pH:
          out[i][f][nk][nj] = np.sum(xi[:, k:k+HH, j:j+WW] * w0) + b0
          k += stride
          nk += 1
        j += stride
        nj += 1

  cache = (x, w, b, conv_param)
  return out, cache


def crop_params(w0, x0, k, j, H, W, HH, WW):
  kup, kdown = (max(0, k), min(k + HH, H))
  jleft, jright = (max(0, j), min(j + WW, W))
  if (kup > k):
    w0 = w0[:, 0-k:, :]
    x0 = np.pad(x0, ((0, 0), (-k, 0), (0, 0)), mode = 'constant')
  if (kdown < k + HH):
    w0 = w0[:, :H-k, :]
    x0 = np.pad(x0, ((0, 0), (0, k + HH - H), (0, 0)),
        mode = 'constant')
  if (jleft > j):
    w0 = w0[:, :, 0-j:]
    x0 = np.pad(x0, ((0, 0), (0, 0), (-j, 0)), mode = 'constant')
  if (jright < j + WW):
    w0 = w0[:, :, :W-j]
    x0 = np.pad(x0, ((0, 0), (0, 0), (0, j + WW - W)),
        mode = 'constant')
  return w0, x0


def conv_backward_naive(dout, cache):
  """
  A naive implementation of the backward pass for a convolutional layer.

  Inputs:
  - dout: Upstream derivatives.
  - cache: A tuple of (x, w, b, conv_param) as in conv_forward_naive

  Returns a tuple of:
  - dx: Gradient with respect to x
  - dw: Gradient with respect to w
  - db: Gradient with respect to b
  """
  dx, dw, db = None, None, None

  x, w, b, conv_param = cache
  stride = conv_param['stride']
  pad = conv_param['pad']
  N, _, H, W = x.shape
  F, _, HH, WW = w.shape

  dx = np.zeros(x.shape)
  dw = np.zeros(w.shape)
  db = np.zeros(b.shape)

  for i in xrange(N):
    for f in xrange(F):
      nk = 0
      for k in xrange(-pad, -HH + H + pad + 1, stride):
        nj = 0
        for j in xrange(-pad, -WW + W + pad + 1, stride):
          dout_element = dout[i][f][nk][nj]

          kup, kdown = (max(0, k), min(k + HH, H))
          jleft, jright = (max(0, j), min(j + WW, W))
          HH_ = kdown - kup
          WW_ = jright - jleft

          w0, x0 = crop_params(w[f], x[i][:, kup:kdown, jleft:jright],
              k, j, H, W, HH, WW)

          dx0 = dout_element * w0
          dx[i][:, kup:kdown, jleft:jright] += dx0

          dw0 = dout_element * x0
          dw[f] += dw0

          nj += 1
        nk += 1

  db = np.sum(dout, axis=(0, 2, 3))
  return dx, dw, db


def max_pool_forward_naive(x, pool_param):
  """
  A naive implementation of the forward pass for a max pooling layer.

  Inputs:
  - x: Input data, of shape (N, C, H, W)
  - pool_param: dictionary with the following keys:
    - 'pool_height': The height of each pooling region
    - 'pool_width': The width of each pooling region
    - 'stride': The distance between adjacent pooling regions

  Returns a tuple of:
  - out: Output data
  - cache: (x, pool_param)
  """
  out = None

  stride = pool_param['stride']
  pool_height = pool_param['pool_height']
  pool_width = pool_param['pool_width']

  N, C, H, W = x.shape
  H_ = 1 + (H - pool_height) / stride
  W_ = 1 + (W - pool_width) / stride
  out = np.zeros((N, C, H_, W_))

  for i in xrange(N):
    xi = x[i]
    nk = 0
    for k in xrange(0, H - pool_height + 1, stride):
      nj = 0
      for j in xrange(0, W - pool_width + 1, stride):
        out[i][:, nk, nj] = np.amax(xi[:, k:k+pool_height, j:j+pool_width],
            axis = (1, 2))
        nj += 1
      nk += 1
  cache = (x, pool_param)
  return out, cache


def max_pool_backward_naive(dout, cache):
  """
  A naive implementation of the backward pass for a max pooling layer.

  Inputs:
  - dout: Upstream derivatives
  - cache: A tuple of (x, pool_param) as in the forward pass.

  Returns:
  - dx: Gradient with respect to x
  """
  dx = None

  x, pool_param = cache
  HH = pool_param['pool_height']
  WW = pool_param['pool_width']
  stride = pool_param['stride']
  N, C, H, W = x.shape
  Hp = 1 + (H - HH) / stride
  Wp = 1 + (W - WW) / stride

  dx = np.zeros_like(x)

  for i in xrange(N):
    for j in xrange(C):
      for k in xrange(Hp):
        hs = k * stride
        for l in xrange(Wp):
          ws = l * stride

          # Window (C, HH, WW)
          window = x[i, j, hs:hs+HH, ws:ws+WW]
          m = np.max(window)

          # Gradient of max is indicator
          dx[i, j, hs:hs+HH, ws:ws+WW] += (window == m) * dout[i, j, k, l]

  return dx

def reshape_to_bn(X, N, C, H, W):
  return np.swapaxes(X, 0, 1).reshape(C, -1).T

def reshape_from_bn(out, N, C, H, W):
  return np.swapaxes(out.T.reshape(C, N, H, W), 0, 1)

def spatial_batchnorm_forward(x, gamma, beta, bn_param):
  """
  Computes the forward pass for spatial batch normalization.

  Inputs:
  - x: Input data of shape (N, C, H, W)
  - gamma: Scale parameter, of shape (C,)
  - beta: Shift parameter, of shape (C,)
  - bn_param: Dictionary with the following keys:
    - mode: 'train' or 'test'; required
    - eps: Constant for numeric stability
    - momentum: Constant for running mean / variance. momentum=0 means that
      old information is discarded completely at every time step, while
      momentum=1 means that new information is never incorporated. The
      default of momentum=0.9 should work well in most situations.
    - running_mean: Array of shape (D,) giving running mean of features
    - running_var Array of shape (D,) giving running variance of features

  Returns a tuple of:
  - out: Output data, of shape (N, C, H, W)
  - cache: Values needed for the backward pass
  """
  out, cache = None, None

  out, cache = batchnorm_forward(reshape_to_bn(x, *x.shape),
      gamma, beta, bn_param)
  out = reshape_from_bn(out, *x.shape)
  cache['X_dimensions'] = x.shape

  return out, cache


def spatial_batchnorm_backward(dout, cache):
  """
  Computes the backward pass for spatial batch normalization.

  Inputs:
  - dout: Upstream derivatives, of shape (N, C, H, W)
  - cache: Values from the forward pass

  Returns a tuple of:
  - dx: Gradient with respect to inputs, of shape (N, C, H, W)
  - dgamma: Gradient with respect to scale parameter, of shape (C,)
  - dbeta: Gradient with respect to shift parameter, of shape (C,)
  """
  dx, dgamma, dbeta = None, None, None

  x_shape = cache['X_dimensions']
  cache['X'] = reshape_to_bn(cache['X'], *x_shape)
  cache['X_normalized'] = reshape_to_bn(cache['X_normalized'], *x_shape)
  dout = reshape_to_bn(dout, *x_shape)

  dx, dgamma, dbeta = batchnorm_backward(dout, cache)
  dx = reshape_from_bn(dx, *x_shape)

  return dx, dgamma, dbeta


def svm_loss(x, y):
  """
  Computes the loss and gradient using for multiclass SVM classification.

  Inputs:
  - x: Input data, of shape (N, C) where x[i, j] is the score for the jth class
    for the ith input.
  - y: Vector of labels, of shape (N,) where y[i] is the label for x[i] and
    0 <= y[i] < C

  Returns a tuple of:
  - loss: Scalar giving the loss
  - dx: Gradient of the loss with respect to x
  """
  N = x.shape[0]
  correct_class_scores = x[np.arange(N), y]
  margins = np.maximum(0, x - correct_class_scores[:, np.newaxis] + 1.0)
  margins[np.arange(N), y] = 0
  loss = np.sum(margins) / N
  num_pos = np.sum(margins > 0, axis=1)
  dx = np.zeros_like(x)
  dx[margins > 0] = 1
  dx[np.arange(N), y] -= num_pos
  dx /= N
  return loss, dx


def softmax_loss(x, y):
  """
  Computes the loss and gradient for softmax classification.

  Inputs:
  - x: Input data, of shape (N, C) where x[i, j] is the score for the jth class
    for the ith input.
  - y: Vector of labels, of shape (N,) where y[i] is the label for x[i] and
    0 <= y[i] < C

  Returns a tuple of:
  - loss: Scalar giving the loss
  - dx: Gradient of the loss with respect to x
  """
  probs = np.exp(x - np.max(x, axis=1, keepdims=True))
  probs /= np.sum(probs, axis=1, keepdims=True)
  N = x.shape[0]
  loss = -np.sum(np.log(probs[np.arange(N), y])) / N
  dx = probs.copy()
  dx[np.arange(N), y] -= 1
  dx /= N
  return loss, dx
