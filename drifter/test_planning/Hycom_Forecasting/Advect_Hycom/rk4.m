% This function uses the 4th order runge kutta method to calculate a change in 
% position on a lat-lon grid using a 2D+time velocity field
%
%

% Alex Andriatis
% 10-15-2020

function [newlon,newlat] = rk4(lon,lat,gridlon,gridlat,u,v,dt)

  ot = size(u,3);

  % First step, xa xadot, ya, yadot
    % Find u and v corresponding to current lat,lon
      [~,xI]=closest(gridlon,lon,1);
      [~,yI]=closest(gridlat,lat,1);
      un = u(xI,yI,1);
      vn = v(xI,yI,1);
    % Calculate the distance step based on that u and v
      dx = dt/2*un;
      dy = dt/2*vn;
      [xa,ya] = xy2ll(dx,dy,lon,lat);
    % Find velocities at the new intermediate points
      [~,xI]=closest(gridlon,xa,1);
      [~,yI]=closest(gridlat,ya,1);
      if ot==3
       ua = u(xI,yI,2);
       va = v(xI,yI,2);
      else
       ua = u(xI,yI,1);
       va = v(xI,yI,1);
      end

  % Second step, xb,yb,xbdot,ybdot
    % Calculate the distance step based on that u and v
      dx = dt/2*ua;
      dy = dt/2*va;
      [xb,yb] = xy2ll(dx,dy,lon,lat);
    % Find velocities at the new intermediate points
      [~,xI]=closest(gridlon,xb,1);
      [~,yI]=closest(gridlat,yb,1);
      if ot==3
       ub = u(xI,yI,2);
       vb = v(xI,yI,2);
      else
       ub = u(xI,yI,1);
       vb = v(xI,yI,1);
      end

  % Third step, xstar,ystar,xstardot,ystardot
    % Calculate the distance step based on that u and v
      dx = dt*ub;
      dy = dt*vb;
      [xstar,ystar] = xy2ll(dx,dy,lon,lat);
    % Find velocities at the new intermediate points
      [~,xI]=closest(gridlon,xstar,1);
      [~,yI]=closest(gridlat,ystar,1);
      if ot==3
       ustar = u(xI,yI,3);
       vstar = v(xI,yI,3);
      elseif ot==2
       ustar = u(xI,yI,2);
       vstar = v(xI,yI,2);
      elseif ot==1
       ustar = u(xI,yI,1);
       vstar = v(xI,yI,1);
      else
       error('Bad ot')
      end

  % Final step, calculate new positions
      dx = dt*(1/6*un+1/3*ua+1/3*ub+1/6*ustar);
      dy = dt*(1/6*vn+1/3*va+1/3*vb+1/6*vstar);

      [newlon,newlat] = xy2ll(dx,dy,lon,lat);

      sprintf('Old coordinates: %0.2f N, %0.2f E, New coordinates: %0.2f N, %0.2f E \n',lat,lon,newlat,newlon);
end

