
# ./gen_hamm_dct.py
# script generateing NN initialization for training with TNet
#     
# author: Karel Vesely
#

import math, random
import sys


from optparse import OptionParser

parser = OptionParser()
parser.add_option('--dim', dest='dim', help='d1:d2:d3 layer dimensions in the network')
parser.add_option('--sparse', dest='sparse', help='each unit is connected to n randomly chosen units in the previous layer', default=-1)
parser.add_option('--gauss', dest='gauss', help='use gaussian noise for weights', action='store_true', default=False)
parser.add_option('--constbias', dest='constbias', help='all bias set to const', default='no')
parser.add_option('--negbias', dest='negbias', help='use uniform [-4.1,-3.9] for bias (defaultall 0.0)', action='store_true', default=False)
parser.add_option('--inputscale', dest='inputscale', help='scale the weights by 3/sqrt(Ninputs)', action='store_true', default=False)
parser.add_option('--linBNdim', dest='linBNdim', help='dim of linear bottleneck (sigmoids will be omitted, bias will be zero)',default=0)
(options, args) = parser.parse_args()

if(options.dim == None):
    parser.print_help()
    sys.exit(1)


dimStrL = options.dim.split(':')

dimL = []
for i in range(len(dimStrL)):
    dimL.append(int(dimStrL[i]))


#print dimL,'linBN',options.linBNdim

for layer in range(len(dimL)-1):
    print '<biasedlinearity>', dimL[layer+1], dimL[layer]
    print 'm', dimL[layer+1], dimL[layer]
    for row in range(dimL[layer+1]):
        if (options.sparse > 0):
            spos = range(dimL[layer]);
            random.shuffle(spos);
            spos = spos[:int(options.sparse)];
        for col in range(dimL[layer]):
            if (options.sparse):
                if (col in spos):
                    print 0.1*random.gauss(0.0,1.0),
                else:
                    print 0.0,
            elif(options.gauss):
                if(options.inputscale):
                    print 3/math.sqrt(dimL[layer])*random.gauss(0.0,1.0),
                else:
                    print 0.1*random.gauss(0.0,1.0),
            else:
                if(options.inputscale):
                    print (random.random()-0.5)*2*3/math.sqrt(dimL[layer]),
                else:
                    print random.random()/5.0-0.1, 
        print
    print 'v', dimL[layer+1]
    for idx in range(dimL[layer+1]):
        if (options.constbias != 'no'):
            print options.constbias,
        elif(int(options.linBNdim) == dimL[layer+1]):
            print '0.0',
        elif(layer == len(dimL)-2):
            print '0.0',
        elif(options.negbias):
            print random.random()/5.0-4.1,
        else:
            print '0.0',
    print

    if(int(options.linBNdim) != dimL[layer+1]):
        if(layer == len(dimL)-2):
            print '<softmax>', dimL[layer+1], dimL[layer+1]
        else:
            print '<sigmoid>', dimL[layer+1], dimL[layer+1]





