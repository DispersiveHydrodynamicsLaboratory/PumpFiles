% Calculate solitary wave solution with amplitude A for vector xi >= 0, m = 1, n > 1
function u = get_soli(xi,A,n,tol)

  u = zeros(size(xi));
  % Check that we aren't trying to evaluate the function at too large of xi
  ximax = soli_integral(1+1e-11,A,n,tol);
  if max(xi) > ximax
     error(['Max xi = ',num2str(max(xi)),' > max allowed = ',num2str(ximax)]);
  end
  for ii=1:length(xi)
	 if ii > 1 % Assume xi is increasing so u is decreasing (use bisection)
        u(ii) = fzero(@(z) soli_integral(z,A,n,tol) - xi(ii),[1+1e-11,u(ii-1)],tol);
	 else
	    u(ii) = fzero(@(z) soli_integral(z,A,n,tol) - xi(ii),[1+1e-11,A],tol);
     end
  end

