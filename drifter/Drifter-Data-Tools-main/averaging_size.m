index = 1;
means = zeros(300,1);

while(index<=300)
    means(index) = mean(diff(Setpoint.z(1:index))/Model_Params.dt);
    index = index + 1;
end