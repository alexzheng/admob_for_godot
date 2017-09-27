#include "register_types.h"
#include "object_type_db.h"
#include "core/globals.h"
#include "ios/src/admob.h"

void register_admob_types() {
    Globals::get_singleton()->add_singleton(Globals::Singleton("AdMob", memnew(Admob)));
}

void unregister_admob_types() {
}
