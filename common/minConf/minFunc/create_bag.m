function B = create_bag(Nimgs,n_per_img)
    A1 = ones(1,n_per_img);
    B = zeros(Nimgs, Nimgs * n_per_img);
    st = 1;
    ed = n_per_img;
    for i=1:Nimgs
        B(i, st:ed) = A1;
        st = st + n_per_img;
        ed = ed + n_per_img;
    end
end