"""
    markov_link(loss, param, error, error_scale, perturb)

Compute one link in a markov chain given the function `loss(param)`,
the initial parameter `param`, the initial error `error`,
the perturbation function `perturb`, and the error_scale `error_scale`.
"""
function markov_link(loss, param, error, error_scale, perturb)
    test_param = perturb(param)
    test_error = loss(test_param)
    d_error = (error - test_error) / error_scale
    if take_step(d_error)
        new_error = test_error
        new_param = test_param
    else
        new_error = error
        new_param = param
    end
    return new_param, new_error, test_param, test_error
end

function markov_chain(loss, init_param, perturb, error_scale, nt)
    param = ones(length(init_param), nt+1)
    @views @. param[:, 1] = init_param

    test_param = deepcopy(param)
    error = ones(nt+1) .* 10^6

    test_error = deepcopy(error)
    error[1] = loss(init_param)
    for i in 1:nt
        new_param, new_error, proposal_param, proposal_error = markov_link(loss, param[:, i], error[i], error_scale, perturb)

        @views @. param[:, i+1] = new_param
        error[i+1] = new_error

        @views @. test_param[:, i+1] = proposal_param
        test_error[i+1] = proposal_error
    end
    # return param, error
end

function markov_chain_extra(loss, init_param, perturb, error_scale, nt)
    param = ones(length(init_param),nt+1)
    @views @. param[:,1] = init_param

    test_param = deepcopy(param)
    error = ones(nt+1) .* 10^6

    test_error = deepcopy(error)
    error[1] = loss(init_param)

    for i in 1:nt
        new_param, new_error, proposal_param, proposal_error = markov_link(
            loss, param[:, i], error[i], error_scale, perturb)

        @views @. param[:,i+1] = new_param
        error[i+1] = new_error

        @views @. test_param[:,i+1] = proposal_aram
        test_error[i+1] = proposal_error
    end

    return param, error, test_param, test_error
end


function markov_chain_with_save(loss, init_param, perturb, error_scale, nt, filename,freq)
    param = ones(length(init_param), nt+1)
    @views @. param[:, 1] = init_param

    # Initialization
    test_param = deepcopy(param)
    error = ones(nt+1) .* 10^6
    test_error = deepcopy(error)
    error[1] = loss(init_param)

    # Chain
    for i in 1:nt
        new_param, new_error, proposal_param, proposal_error = markov_link(
            loss, param[:, i], error[i], error_scale, perturb)

        @views @. param[:, i+1] = new_param
        error[i+1] = new_error

        @views @. test_param[:, i+1] = proposal_param
        test_error[i+1] = proposal_error

        if i % freq == 0
            println("saving index "*string(i))
            @save filename error param
        end
    end
    return param, error
end

take_step(derror) = log(rand(Uniform(0, 1))) < derror