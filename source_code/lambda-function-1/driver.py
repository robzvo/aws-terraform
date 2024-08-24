import utilities as util
def main(payload, context):
    bla = util.utility_function_1()
    return {
        "status" : 200,
        "results": bla
    }