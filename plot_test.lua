require 'gnuplot'

t = torch.range(1, 10)
results = torch.zeros(5, 10)
for j = 1, 5 do
    for i = 1, 10 do
        results[{j, i}] = j*j*i*i
    end
end


gnuplot.plot(t, results:mean(1):view(10))
-- gnuplot.plot({'second', t, results[{2, {}}], '-'})

