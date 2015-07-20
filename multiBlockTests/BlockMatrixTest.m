classdef BlockMatrixTest < matlab.unittest.TestCase
%BLOCKMATRIXTEST Test Suite for BlockMatrix class
%
%   Class BlockMatrixTest
%
%   Example
%   run(BlockMatrixTest);
%
%   See also
%   BlockMatrix

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2015-02-27,    using Matlab 8.4.0.150421 (R2014b)
% Copyright 2015 INRA - BIA-BIBS.

%% Test Functions for constructor
methods (Test)
    
    function test_BlockMatrix(testCase)
        % test for constructor

        % create the BlockMatrix object
        data = reshape(1:28, [4 7]);
        parts = {[2 2], [2 3 2]};
        BM = BlockMatrix(data, parts);

        testCase.verifyEqual(isempty(BM), false);
    end
end


%% Test Functions for advanced computations
methods (Test)
    function test_blockNorm(testCase)
        data = reshape(1:28, [7 4])';
        parts = {[2 2], [2 3 2]};
        BM = BlockMatrix(data, parts);
        
        BM2 = blockNorm(BM);

        % result should be an instance of BlockMatrix
        testCase.assertTrue(isa(BM2, 'BlockMatrix'));
        % block size of result should match block size of input
        testCase.verifyEqual(blockSize(BM), blockSize(BM2));
        % result should be a scalar block matrix (all blocks are 1-by-1).
        testCase.verifyTrue(isScalarBlock(BM2));
    end
    
    function test_fapply(testCase)
        data = reshape(1:28, [7 4])';
        parts = {[2 2], [2 3 2]};
        BM = BlockMatrix(data, parts);
        
        BM2 = fapply(@sqrt, BM);
        
        testCase.verifyEqual(blockSize(BM), blockSize(BM2));
        testCase.verifyEqual(sqrt(data), BM2.data);
    end
end

%% Test Functions for block products
methods (Test)
    function test_blockProduct_ss(testCase)
        data = reshape(1:16, [8 2]);
        scalar = 3;
        
        A = BlockMatrix(data, {[4 4], [1 1]});
        lambda = BlockMatrix.oneBlock(scalar);
        AA = blockProduct_ss(lambda, A);
        
        testCase.verifyEqual(blockSize(A), blockSize(AA));
        testCase.verifyEqual(data * scalar, getMatrix(AA));
    end
    
    function test_blockProduct_sh(testCase)
        dataA = [1 2 3;3 2 1];
        dataB = reshape(1:36, [4 9]);
        
        A = BlockMatrix.oneBlock(dataA);
        B = BlockMatrix(dataB, {[2 2], [3 3 3]});
        X = blockProduct_sh(A, B);
        
        testCase.verifyEqual(blockSize(B), blockSize(X));
        exp = dataB .* repmat(dataA, 2, 3);
        testCase.verifyEqual(exp, getMatrix(X));
    end
    
    function test_blockProduct_su(testCase)
        blockA = [1 2 3;3 2 1];
        A = BlockMatrix.oneBlock(blockA);
        B = BlockMatrix(reshape(1:36, [6 6]), {[3 3], [2 2 2]});
        X = blockProduct_su(A, B);
        
        % verify the dimensions of the result BlockMatrix
        testCase.verifyEqual([4 6], size(X));
        testCase.verifyEqual(blockSize(B), blockSize(X));
        testCase.verifyEqual(IntegerPartition([2 2]), blockDimensions(X, 1));
        testCase.verifyEqual(IntegerPartition([2 2 2]), blockDimensions(X, 2));
        
        % verify that each block correspond to usual product of input
        % blocks
        for iBlock = 1:blockSize(B, 1)
            for jBlock = 1:blockSize(B, 2)
                block = blockA * B{iBlock, jBlock};
                testCase.verifyEqual(block, X{iBlock, jBlock});
            end
        end            
    end
end

%% Test Functions for basic array manipulation
methods (Test)
    function test_size(testCase)
        data = reshape(1:28, [4 7]);
        parts = {[2 2], [2 3 2]};
        BM = BlockMatrix(data, parts);
        
        siz = size(BM);
        testCase.verifyEqual(siz(1), 4);
        testCase.verifyEqual(siz(2), 7);
    end
    
    function test_size_two_outputs(testCase)
        data = reshape(1:28, [4 7]);
        parts = {[2 2], [2 3 2]};
        BM = BlockMatrix(data, parts);
        
        [siz1, siz2] = size(BM);
        testCase.verifyEqual(siz1, 4);
        testCase.verifyEqual(siz2, 7);
    end
    
    function test_blockSize(testCase)
        data = reshape(1:28, [4 7]);
        parts = {[2 2], [2 3 2]};
        BM = BlockMatrix(data, parts);
        
        siz = blockSize(BM);
        testCase.verifyEqual(siz(1), 2);
        testCase.verifyEqual(siz(2), 3);
    end
    
    function test_blockSize_two_outputs(testCase)
        data = reshape(1:28, [4 7]);
        parts = {[2 2], [2 3 2]};
        BM = BlockMatrix(data, parts);
        
        [siz1, siz2] = blockSize(BM);
        testCase.verifyEqual(siz1, 2);
        testCase.verifyEqual(siz2, 3);
    end
    
end


%% Test Functions for testing block matrix nature
methods (Test)
    function test_isOneBlock_true(testCase)
       data = reshape(1:28, [7 4])';
       BM = BlockMatrix(data, {4, 7});
       testCase.verifyTrue(isOneBlock(BM));
    end
    
    function test_isOneBlock_false(testCase)
        data = reshape(1:28, [7 4])';
        BM = BlockMatrix(data, {[2 2], [2 3 2]});
        testCase.verifyFalse(isOneBlock(BM));
    end
    
    function test_isScalarBlock_true(testCase)
        data = reshape(1:28, [7 4])';
        BM = BlockMatrix(data, {ones(1,4), ones(1,7)});
        testCase.verifyTrue(isScalarBlock(BM));
    end
    
    function test_isScalarBlock_false(testCase)
        data = reshape(1:28, [7 4])';
        BM = BlockMatrix(data, {[2 2], [2 3 2]});
        testCase.verifyFalse(isScalarBlock(BM));
    end
    
    function test_isUniformBlock_true(testCase)
       data = reshape(1:24, [6 4])';
       BM = BlockMatrix(data, {[2 2], [3 3]});
       testCase.verifyTrue(isUniformBlock(BM));
    end
    
    function test_isUniformBlock_false(testCase)
       data = reshape(1:24, [6 4])';
       BM = BlockMatrix(data, {[2 2], [4 2]});
       testCase.verifyFalse(isUniformBlock(BM));
    end

    function test_isVectorBlock_true(testCase)
       data = reshape(1:24, [6 4])';
       BM = BlockMatrix(data, {4, [2 2 2]});
       testCase.verifyTrue(isVectorBlock(BM));
    end
    
    function test_isVectorBlock_false(testCase)
       data = reshape(1:24, [6 4])';
       BM = BlockMatrix(data, {[2 2], [4 2]});
       testCase.verifyFalse(isVectorBlock(BM));
    end

end

%% Test Functions for basic array manipulation
methods (Test)

    function test_transpose(testCase)
        % test the transpose method
        
        data = reshape(1:28, [4 7]);
        parts = {[2 2], [2 3 2]};
        BM = BlockMatrix(data, parts);
        
        BM2 = BM';
        
        dim1 = size(BM2, 1);
        dim2 = size(BM2, 2);
        testCase.verifyEqual(dim1, 7);
        testCase.verifyEqual(dim2, 4);
    end
    
    function test_cat_dir1(testCase)
        data = reshape(1:28, [4 7]);
        parts = {[2 2], [2 3 2]};
        BM = BlockMatrix(data, parts);

        BM2 = cat(1, BM, BM);

        dim1 = size(BM2, 1);
        dim2 = size(BM2, 2);
        testCase.verifyEqual(dim1, 8);
        testCase.verifyEqual(dim2, 7);
    end
    
    function test_cat_dir2(testCase)
        data = reshape(1:28, [4 7]);
        parts = {[2 2], [2 3 2]};
        BM = BlockMatrix(data, parts);

        BM2 = cat(2, BM, BM);

        dim1 = size(BM2, 1);
        dim2 = size(BM2, 2);
        testCase.verifyEqual(dim1, 4);
        testCase.verifyEqual(dim2, 14);
    end
    
    function test_horzcat(testCase)
        data = reshape(1:28, [4 7]);
        parts = {[2 2], [2 3 2]};
        BM = BlockMatrix(data, parts);

        BM2 = [BM BM];

        dim1 = size(BM2, 1);
        dim2 = size(BM2, 2);
        testCase.verifyEqual(dim1, 4);
        testCase.verifyEqual(dim2, 14);
    end
    
    function test_vertcat(testCase)
        data = reshape(1:28, [4 7]);
        parts = {[2 2], [2 3 2]};
        BM = BlockMatrix(data, parts);

        BM2 = [BM ; BM];

        dim1 = size(BM2, 1);
        dim2 = size(BM2, 2);
        testCase.verifyEqual(dim1, 8);
        testCase.verifyEqual(dim2, 7);
    end
end


%% Test Functions for overloadig arithmetic operations
methods (Test)
    
    function test_times(testCase)
        data1 = reshape(1:28, [4 7]);
        parts1 = {[2 2], [2 3 2]};
        BM1 = BlockMatrix(data1, parts1);
        
        data2 = reshape(1:35, [7 5]);
        parts2 = {[2 3 2], [2 1 2]};
        BM2 = BlockMatrix(data2, parts2);
        
        data3 = data1 * data2;
        BM3 = BM1 * BM2;
        testCase.verifyEqual(data3, BM3.data, 'AbsTol', .1);
    end

end

%% Test Functions for array indexing
methods (Test)
    
    function test_subsref_parens(testCase)
        BM = BlockMatrix(reshape(1:28, [7 4])', [2 2], [2 3 2]);
        res = BM(2, 3);
        testCase.verifyEqual(10, res, 'AbsTol', .1);
    end
    
    function test_subsref_braces(testCase)
        BM = BlockMatrix(reshape(1:28, [7 4])', [2 2], [2 3 2]);
        res = BM{2, 3};
        testCase.verifyEqual([20 21; 27 28], res, 'AbsTol', .1);
    end

    function test_subsasgn_parens(testCase)
        BM = BlockMatrix(reshape(1:28, [7 4])', [2 2], [2 3 2]);
        BM(2, 3) = 4;
        testCase.verifyEqual(4, BM(2, 3));
    end
    
    function test_subsasgn_braces(testCase)
        BM = BlockMatrix(reshape(1:28, [7 4])', [2 2], [2 2 3]);
        BM{2, 3} = [1 2 3;4 5 6];
        testCase.verifyEqual(4, BM(4, 5));
    end

end

end % end classdef

