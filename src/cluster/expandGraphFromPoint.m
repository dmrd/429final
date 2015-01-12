function mask = expandGraphFromPoint(labeled, nodes, edges, x, y, depth)
    dim = max(edges(:));
    AdjMat = sparse(edges(:,1),edges(:,2),1, dim, dim);
    AdjMat = AdjMat + AdjMat';
    
        class(y)
        class(x)
    label = labeled(int32(y), int32(x));
    if label == 0
        [D,IDX] = bwdist(labeled > 0);
        lin = IDX(y, x);
        [y, x] = ind2sub(size(labeled), lin);
        label = labeled(y, x);
    end
    [disc, pred, closed] = graphtraverse(AdjMat, label, 'Depth', depth, 'Directed', false);
    mask = ismember(labeled, disc);
end